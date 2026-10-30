# At The Movies

A fresh Rails 8.1.4 / Ruby 4.0.7 application for UK cinema listings. SQLite in
all environments; Solid Queue, Cache and Cable; Hotwire, Importmap, Propshaft,
Active Storage, Tailwind and daisyUI. See [docs/rebuild-status.md](docs/rebuild-status.md) for provider checks,
decisions and what remains before going live.

## Run locally

Install Ruby from `.ruby-version`, Bundler, SQLite and libvips (for image variants), then:

```sh
bin/setup --skip-server
bin/dev
```

`bin/dev` runs Puma, Tailwind and the Solid Queue worker. No PostgreSQL or Redis is
needed. In an Amp orb, `.agents/setup` installs dependencies and `amp orb services
ensure` starts supervised services and returns the preview portal.

Seeds deliberately create no fake listings or default operator credentials.
Create an operator in `bin/rails console` with `User.create!(email_address: ...,
password: ..., password_confirmation: ...)`. There is no public registration;
every provisioned user is an operator. Supply passwords privately, not in shell history.

## Imports and metadata

```sh
bin/rails runner 'ImportChainJob.perform_later("cineworld")'   # or curzon, odeon, picturehouse, vue
bin/rails runner 'EnrichPendingFilmsJob.perform_later'
bin/rails runner 'CleanupPerformancesJob.perform_later'
bin/rails imports:status
```

Each chain comes from its own gem: `cineworld_uk`, `curzon_uk`, `odeon_uk`,
`picturehouse_uk` and `vue_uk`, all built on `cinebase`. `Chain` lists them.
`ImportChainJob` loads a chain's cinemas and queues `ImportChainPerformancesJob`
for each one.

Cineworld, Curzon, ODEON and Picturehouse run on Vista's OCAPI and need a guest
token. The worker acquires one with the gem's bundled `curl-impersonate` and
reuses it in memory until an hour before it expires; a rejected token is dropped
so the retry fetches a new one. No token is stored. The app asks OCAPI for every advertised business date for each
cinema, then loads the showtimes on those dates, so events months ahead are
included. Vue needs no token and returns every advertised date in one request;
`Chain::ADVERTISED_HORIZON` (one year) only bounds it. There is no other
app-imposed future cutoff.

Cinema identity is the chain's venue ID, stored as an external identifier such
as `cineworld_venue`. Imports keep operator edits to names and addresses, and
update only brand and screenings URL. Coordinates come from the chain's gem when
it supplies them, and only fill a cinema that has none, so operator edits stay.
"Near me" sorts cinemas without coordinates last. ODEON supplies no postcodes.

Case, punctuation and whitespace-normalised title aliases resolve repeated titles.
Titles shared by remakes/events may need manual triage; a title is not a film's public ID.

Configure `TMDB_ACCESS_TOKEN` (TMDB API read-access bearer token) or
`credentials.tmdb.access_token` for enrichment. No live TMDB calls are made by
tests. Exact single matches enrich automatically; ambiguous matches stay in
`/operator/films`. Operators can edit films/cinemas, add aliases, choose TMDB IDs,
mark no-match, upload images, set trusted TMDB image-source URLs and merge films.
Image fetching accepts only HTTPS `image.tmdb.org` image URLs and never follows
redirects to arbitrary hosts. Active Storage owns stored images and variants.

Public listings exclude hidden films. Events and deliberate no-match films stay
visible. What's on requires a current/future showing, independently of cleanup.
Days are midnight-to-midnight in London (not a 06:00 cinema day); today excludes
elapsed showings. Cleanup destroys past performances, maintaining film counters.

Production recurring tasks import Cineworld at 01:00, Curzon at 01:30,
Picturehouse at 02:00, ODEON at 02:30 and Vue at 03:00 London, enrich at 04:00
London and clean up every 10 minutes. Network failures retry five times with backoff; queue
failures remain available in Solid Queue and `imports:status`. Development tasks
are manual to avoid unexpected website requests. Run the worker for queued work.

## Routes and API

HTML: `/`, `/films`, `/cinemas`, `/films/PUBLIC_ID/name-year`,
`/cinemas/PUBLIC_ID/name-locality`, `/cinemas/PUBLIC_ID/performances/today`.
Missing/stale decorative suffixes permanently redirect; detail pages emit canonical links.

Read-only JSON, with conventional objects/arrays and underscore keys:

- `GET /api/cinemas` and `/api/cinemas/PUBLIC_ID`
- `GET /api/films` and `/api/films/PUBLIC_ID`
- `GET /api/cinemas/PUBLIC_ID/performances?date=YYYY-MM-DD`
- `GET /api/films/PUBLIC_ID/performances?date=YYYY-MM-DD`
- `GET /api/films/PUBLIC_ID/cinemas`

Dates also accept `today` or `tomorrow` and default to today. Invalid dates return
400; missing/hidden resources return 404. Film/cinema IDs in JSON are public tokens,
never database integers or slugs. The legacy JSON:API/content negotiation is not retained.

## Checks and maintenance

```sh
bin/ci
bin/rails test:system
bin/rails zeitwerk:check
bin/rails daisyui:install   # deliberately update vendored UI plugins
```

Minitest covers chain imports, aliases, repeat/concurrent import identity, atomic merges and
counters, London/BST boundaries, cleanup, metadata and image idempotency, canonical
URLs, JSON shapes and operator authentication. GitHub Actions runs security, lint,
test and system-test checks. Dependabot updates are grouped and cooled down.
Non-major updates auto-merge once the checks pass; the `Protect master` ruleset
requires all five.

## Deployment

Generated Kamal/Thruster/Docker configuration is retained as a starting point,
not a configured production deployment. Set your hosts, registry and secret store
before deploying. Keep a persistent storage volume and one SQLite writer. Back up
**all four production SQLite databases and Active Storage files**. Add Litestream
only once the actual persistent-storage deployment and recovery process are chosen.
Configure real mail delivery and `config.action_mailer.default_url_options` for
password reset, and keep Rails master keys outside Git. Production needs glibc
Linux (x86-64 or ARM64) for the gems' bundled `curl-impersonate`.
