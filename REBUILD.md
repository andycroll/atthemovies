# At The Movies: repository state and rebuild brief

This document records what the existing application does so it can be rebuilt
from a fresh Rails application without treating old framework code as the
specification.

It reflects the repository as inspected on 26 September 2026. The last commit
in this checkout is dated 21 July 2021.

## Executive summary

At The Movies is a small Rails monolith that:

1. imports UK cinema locations and listings from Cineworld, Odeon, and
   Picturehouse;
2. normalises those listings into cinemas, films, and performances;
3. enriches films with TMDB metadata and images;
4. exposes public HTML listings and a read-only JSON:API API; and
5. provides a basic-authenticated film/cinema triage UI.

The useful parts to preserve are the domain model, import identities, API
contract (if it still has consumers), and manual film-triage workflow. Most of
the infrastructure should be selected afresh. In particular, do not begin by
upgrading this application in place: it is tied to Ruby 2.5.3, Rails 6.0.4,
Bundler 1.17.3, old scraper gems, Delayed Job, Dragonfly, Sprockets/Turbolinks,
and Rails 5.1 defaults.

The largest unknown is not Rails; it is whether the three scraper gems still
work against their cinema websites and whether anything still consumes the v1
API. Establish those facts before reproducing all current behaviour.

## Current stack

| Area | Current implementation |
| --- | --- |
| Language/framework | Ruby 2.5.3, Rails 6.0.4, `config.load_defaults 5.1` |
| Database | PostgreSQL; UUID primary keys; `pg_trgm`, `pgcrypto`, `uuid-ossp` |
| Background jobs | Active Job with Delayed Job in the primary database |
| Web server | Puma 4.3.6 |
| API rendering | ActiveModelSerializers 0.10.10, JSON:API adapter |
| Front end | ERB, Bootstrap 3 from a CDN, Sprockets, Turbolinks, small vanilla JS |
| Search/slugs | Textacular and Stringex |
| Geocoding | Geocoder; coordinates are stored on cinemas |
| External metadata | `themoviedb` gem and the TMDB API |
| Listing sources | `cineworld_uk`, `odeon_uk`, and `picturehouse_uk` gems |
| Images | Dragonfly + ImageMagick, persisted to S3 |
| Cache | Memcached/Dalli in production; memory/null cache elsewhere |
| Monitoring | Rollbar, Skylight, Lograge, Rack Timeout |
| Tests | RSpec request/model/job/service specs; Factory Bot, Timecop, SimpleCov |
| Deployment shape | Heroku-style `release`, `web`, and `worker` Procfile processes |
| CI | Both CircleCI and Travis configurations, using PostgreSQL 11/9.6-era images |

There is no committed scheduler configuration. The README is the only source
for task cadence.

## Domain model

All three domain tables use UUID primary keys. The database currently has no
foreign-key constraints and few indexes; this should not be copied blindly.

### Cinema

A physical venue imported from a provider.

- Identity used by imports: `name + brand + brand_identifier`.
- Public slug: `url`, regenerated from `name`.
- Provider fields: `brand`, `brand_identifier`, `screenings_url`, and an unused
  `information_url`.
- Address fields: street/extended address, locality, region, postal code,
  country, and country code.
- Coordinates: decimal latitude/longitude, populated by a geocoding callback
  when key address fields change.
- Has many ordered performances.
- Nearby search accepts latitude/longitude and asks Geocoder for venues within
  1,000 default distance units, ordered by distance.

### Film

A normalised title shared by performances from all providers.

- Required `name` and generated `url` slug.
- TMDB/IMDb metadata: identifiers, year, runtime, tagline, overview, poster,
  and backdrop.
- Original image URLs are retained separately from the processed S3 URLs.
- `tmdb_possibles` stores candidate TMDB IDs for manual triage.
- `information_added` marks metadata enrichment as complete (including a
  deliberate manual “no information” decision).
- `alternate_names` lets future provider titles resolve to an existing film.
- `name_hashes` stores sorted, lower-case alphanumeric title signatures. It is
  displayed in the admin UI but is not used by current film lookup.
- `event` and `hidden` are admin flags, but neither affects public queries in
  the current code.
- `performances_count` is an Active Record counter cache. “What’s on” means
  this value is greater than zero, sorted descending; it is not independently
  constrained to future performances.
- Has many performances and distinct cinemas through performances.

Film lookup during import first tries the slug generated from the incoming
name, then PostgreSQL array containment against `alternate_names`, otherwise it
creates a film. Similar-title search uses Textacular full-text/trigram-style
search, not `name_hashes`.

### Performance

A showing of a film at a cinema.

- Belongs to a cinema and film.
- Required fields: `cinema_id`, `film_id`, `dimension`, `variant`, and
  `starting_at` (the model does not explicitly validate `variant`, although the
  database disallows null).
- Import identity: `cinema + film + dimension + starting_at`. A repeated import
  updates `variant` and `updated_at` rather than creating a new record.
- `dimension` and `variant` are lower-cased before save.
- Date queries are ordered by start time. A query for today excludes showings
  that have already started; other dates cover the calendar day.
- The application time zone is `Europe/London`.

There is an unused `PerformanceGrouper` which treats showings before 06:00 as
part of the previous cinema day. Current controllers do not use that rule.

## Data flows

### Cinema and performance ingestion

```text
scheduled rake task
  -> provider scraper gem
  -> one Active Job per cinema/performance
  -> normalised Cinema / Film / Performance rows
  -> a newly named Film queues TMDB candidate lookup
```

The provider adapters expect:

- `Provider::Cinema.all`, with each result exposing `full_name`, `brand`, `id`,
  `address`, and `url`; and
- `Provider::Performance.at(brand_identifier)`, with each result exposing
  `film_name`, `dimension`, `variant[]`, and `starting_at`.

Configured providers are Cineworld, Odeon, and Picturehouse. These are scraper
gems rather than stable first-party APIs and are therefore the highest-risk
dependencies in a reboot.

Cinema imports only fill the address when the existing row has no street
address, but always update `screenings_url`. Performance imports create or
reuse a film and upsert using the identity described above. There is no
database uniqueness constraint, so concurrent jobs can create duplicates.

### Film enrichment

```text
new/renamed Film
  -> search TMDB
  -> save candidate IDs
  -> if exactly one candidate and normalised titles match:
       select it automatically
  -> otherwise: operator selects a candidate in triage UI
  -> fetch TMDB details
  -> queue poster and backdrop processing
  -> resize/crop with ImageMagick and store in S3
```

Changing a film’s TMDB ID clears `information_added` and queues enrichment.
Changing either source image URI queues image processing. The current callback
and job combination can enqueue image work more than once; preserve the outcome,
not that incidental job sequence.

### Retention

`cleanup:past_performances` destroys every performance whose `starting_at` is
before the current time. Because film counts are a counter cache, that cleanup
also determines which films appear in “what’s on”. Films and cinemas remain.

The documented schedule is:

- nightly: import all providers’ cinemas and performances, find TMDB candidate
  IDs, and hydrate films;
- every 10 minutes: delete past performances.

## User-facing behaviour

### Public HTML

- `/`: links to cinemas and films and offers browser-geolocation-based nearby
  cinemas when supported.
- `/cinemas`: all cinemas, optionally sorted by distance via
  `?near=LATITUDE,LONGITUDE`.
- `/cinemas/:slug`: venue address, provider listings URL, and links to 15 days
  of performances.
- `/cinemas/:slug/performances/:when`: performances for `today`, `tomorrow`, or
  `YYYY-MM-DD`; the undated nested route redirects to today.
- `/films`: films with a non-zero performance counter, or title search results.
- `/films/:slug`: metadata and all associated cinemas (not date-filtered).

### Operator UI

HTTP Basic authentication protects cinema edit/update and film
edit/update/merge/triage actions. There are no users, roles, sessions, or
audit records.

The operator can:

- edit cinema names and addresses;
- search and triage unenriched films;
- choose a TMDB candidate or enter a TMDB ID;
- mark a record as an event, hidden, or intentionally without metadata;
- set image source URLs; and
- merge duplicate films, moving performances and retaining the removed film’s
  name as an alternate name.

Public read pages and the API require no authentication.

## v1 API contract

API routes share the HTML paths. A request reaches the API controller when it
uses `.json` or an `Accept: application/vnd.atthemovies.v1` header. Responses
use JSON:API envelopes and dash-separated attribute names.

| Endpoint | Behaviour |
| --- | --- |
| `GET /cinemas` | All cinemas |
| `GET /films` | Films with `performances_count > 0`, busiest first |
| `GET /cinemas/:cinema_id/performances?date=YYYYMMDD` | That cinema’s performances on a date |
| `GET /films/:film_id/performances?date=YYYYMMDD` | That film’s performances on a date |
| `GET /films/:film_id/cinemas` | Distinct cinemas with any performance for the film |

The API uses UUIDs, not HTML slugs, in nested routes. Performance resources
include `cinema` and `film` relationships containing IDs. The exact attributes
are asserted by request specs:

- cinema: brand, country, country code, extended address, latitude, locality,
  longitude, postal code, name, street address, URL;
- film: backdrop, name, overview, performance count, poster, runtime, tagline,
  TMDB ID, year; and
- performance: dimension, starting time, variant, and cinema/film relationships.

Before retaining this exact shape, check API traffic or known clients. There is
no API documentation, authentication, rate limiting, pagination, or explicit
deprecation/version migration mechanism beyond content negotiation.

## External services and configuration

The checked-in `.env.example` names S3, TMDB, HTTP Basic, and secret-key values.
Production also refers to variables absent from that example:

- `MEMCACHIER_SERVERS`, `MEMCACHIER_USERNAME`, `MEMCACHIER_PASSWORD`;
- `ROLLBAR_ACCESS_TOKEN`, optionally `ROLLBAR_ENV`;
- `SKYLIGHT_AUTHENTICATION` (via Skylight configuration);
- standard Rails/Puma variables such as `PORT`, `RAILS_MAX_THREADS`,
  `RAILS_LOG_TO_STDOUT`, and `RAILS_SERVE_STATIC_FILES`.

`REDIS_PROVIDER` appears in `.env.example` but is not used. Action Cable’s
generated config refers to `REDIS_URL`, although the application has no cable
channels. Active Storage is configured but not used. The production database
configuration is expected to come from the deployment environment rather than
`config/database.yml`.

The Dragonfly initializer contains a checked-in signing secret. Treat it as
public and do not reuse it. Move all new secrets to Rails credentials or the
deployment secret store, and rotate real service credentials during migration.

## Known defects and accidental behaviour

These are observations, not requirements for the replacement:

1. `import:films:external_information` references
   `Import::ExternalFilmInformation`, which does not exist.
2. The film edit form posts `new_name`, while the controller checks
   `alternate_name`; adding an alternate name from that form does not work.
3. The film edit form exposes `url` and `runtime`, while strong parameters omit
   `url` and permit nonexistent `running_time`; those edits are ignored.
4. `hidden` and `event` are written by triage but are not used to filter films
   in HTML or API listings.
5. There are no foreign keys, uniqueness constraints, or composite performance
   lookup index. Associations do not specify dependent cleanup.
6. Date parameter validation in API controllers is loose and duplicated.
7. Import jobs are not transactionally idempotent under concurrency.
8. Provider fetch, TMDB fetch, geocoding, and image processing have no explicit
   timeout/retry/backoff policy in application code.
9. Image URLs are protocol-relative (`//...`) and old generated S3 objects are
   never deleted.
10. The live UI uses normal calendar-day performance grouping; the tested 06:00
    “cinema day” presenter is dead code.
11. The JavaScript initialisation fallback invokes `init` while registering the
    DOM event rather than passing it as a callback.
12. Both CI systems and their service images are obsolete; neither is useful as
    a blueprint for the replacement.

## Rebuild recommendation

Start with a currently supported Ruby and Rails release and PostgreSQL. Generate
a normal full-stack application rather than copying configuration files. Decide
the job, cache, asset, and image-storage choices from current Rails defaults and
the intended deployment platform.

### 1. Prove the boundaries first

- Identify active consumers of the v1 API and record representative production
  responses if compatibility is required.
- Test each cinema provider against its current website. Prefer maintained,
  separately testable adapters over embedding old scraper gems unchanged.
- Decide whether existing PostgreSQL data and S3 images are valuable enough to
  migrate, or whether cinemas and listings can be re-imported from scratch.
- Confirm the desired “cinema day” boundary, past-performance retention, and
  meaning of `hidden`/`event` before implementing them.

### 2. Build the smallest useful vertical slice

1. Create fresh `Cinema`, `Film`, and `Performance` migrations from the current
   schema, not by replaying the nine historical migrations.
2. Add foreign keys and indexes. At minimum, consider uniqueness for provider
   cinema identity and performance import identity; decide how title aliases
   should be normalised before constraining films.
3. Implement one provider adapter, its import job, and idempotency tests.
4. Implement current/future listings and cleanup or expiry behaviour.
5. Add public read pages or the API according to known consumers.

### 3. Restore enrichment and operations

- Add TMDB lookup and an explicit enrichment state rather than a single boolean
  if operators need to distinguish pending, matched, no match, event, hidden,
  and failed states.
- Use current Rails-supported file storage/image variants unless there is a
  demonstrated reason to preserve Dragonfly paths.
- Rebuild the small triage workflow with real authentication appropriate to the
  deployment; retain Basic Auth only if that is a conscious operational choice.
- Schedule imports and cleanup explicitly on the chosen platform and make
  failures observable.

### 4. Migrate deliberately

- Preserve UUIDs if importing the old database or maintaining API identity.
- Recalculate `performances_count` rather than trusting stale counters.
- Validate orphan counts before adding foreign keys.
- Deduplicate cinemas and performances before adding unique indexes.
- Copy existing image URLs only if the old S3 bucket remains available;
  otherwise regenerate from valid TMDB source paths.
- Run old and new imports side-by-side against a sample of cinemas and compare
  film matching, start times around midnight/BST changes, dimensions, and
  variants before cutover.

## Behaviour worth carrying into tests

The existing suite has broad unit/request coverage, but port behaviour rather
than copying old test implementation. High-value replacement tests are:

- repeated and concurrent imports do not duplicate a cinema or performance;
- provider title aliases resolve to the intended film;
- film merge is atomic, moves all performances, preserves the old title, and
  leaves counter caches correct;
- today excludes elapsed performances and date boundaries behave correctly in
  `Europe/London`, including BST transitions and any chosen early-hours rule;
- deleting/expiring performances updates “what’s on” correctly;
- selecting a TMDB match results in metadata and one set of stored images;
- hidden/event/no-match states have explicitly agreed public behaviour;
- API response fixtures remain compatible if the v1 API must be preserved; and
- unauthenticated users cannot reach any operator mutation.

## Things not worth porting by default

- Rails 5.1 compatibility initializers and generated Rails 6 scaffolding;
- Delayed Job’s table and worker setup;
- Dragonfly middleware and its public signing secret;
- Turbolinks/Sprockets page-initialisation plumbing;
- Bootstrap 3 CDN markup and old pagination partials;
- crawler-specific exception handling;
- dual legacy CI configuration;
- unused Action Cable, Active Storage, Redis, and `PerformanceGrouper` setup;
- old monitoring vendors unless they remain the chosen services; and
- historical migrations whose final state is already represented by the schema.

The old repository should remain available as a behavioural reference until
provider ingestion, data migration, operator triage, and any required API
compatibility have all been verified in the replacement.
