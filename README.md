# At The Movies

A fresh Rails 8.1.4 / Ruby 4.0.7 application for UK cinema listings. SQLite in
all environments; Solid Queue, Cache and Cable; Hotwire, Importmap, Propshaft,
Active Storage, Tailwind and daisyUI. See [REBUILD.md](REBUILD.md) for the original
brief and [docs/rebuild-status.md](docs/rebuild-status.md) for boundaries and cutover gates.

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
bin/rails runner 'ImportPicturehouseJob.perform_later'
bin/rails runner 'EnrichPendingFilmsJob.perform_later'
bin/rails runner 'CleanupPerformancesJob.perform_later'
bin/rails imports:status
```

Picturehouse is the first live-verified provider. Cinema discovery and listings
are fresh adapters, not the old gem. Numeric venue IDs are separate from website
slugs, sessions are filtered by venue, and offset-free times use Europe/London.
Imports preserve manual venue names/addresses and use database-enforced identities.
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

Production recurring tasks import at 02:00 London, enrich at 04:00 London and
clean up every 10 minutes. Network failures retry five times with backoff; queue
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

Minitest covers aliases, repeat/concurrent import identity, atomic merges and
counters, London/BST boundaries, cleanup, metadata and image idempotency, canonical
URLs, JSON shapes and operator authentication. GitHub Actions runs security, lint,
test and system-test checks. Dependabot updates are grouped and cooled down; its
automerge workflow requires repository auto-merge and required CI branch protection.
Those remote settings have not been changed.

## Deployment

Generated Kamal/Thruster/Docker configuration is retained as a starting point,
not a configured production deployment. Set your hosts, registry and secret store
before deploying. Keep a persistent storage volume and one SQLite writer. Back up
**all four production SQLite databases and Active Storage files**. Add Litestream
only once the actual persistent-storage deployment and recovery process are chosen.
Configure real mail delivery and `config.action_mailer.default_url_options` for
password reset, rotate old credentials, and keep Rails master keys outside Git.
Do not deploy or cut over until the outstanding checks in `docs/rebuild-status.md`
are resolved.
