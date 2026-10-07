# Rebuild execution and remaining cutover gates

## Replacement delivered locally

Generated full-stack Rails 8.1.4 on Ruby 4.0.7, rechecked against Ruby's downloads
and RubyGems on 7 October 2026. Booted the fresh app before adding domain code.
Applied the inspected daisyUI, CI, Procfile.dev and Dependabot templates. The
Dependabot template skips an existing configuration; grouping/cooldowns were
added to the generated config explicitly. Retained framework defaults, with a
development SQLite queue database so the Procfile's worker actually runs jobs.

The old application has been removed from the working tree and its orb-local
reference copy deleted. Historical source remains in Git history; it is not a
production data backup. No existing production data, S3 assets or credentials were copied.
Fresh cinemas/listings can be re-imported; preserving curated titles, aliases,
legacy UUID redirects and image assets is a separate migration decision requiring
a real export. Merging this replacement does not perform a production cutover or
configure a deployment.

## Provider boundary checks (7 October 2026)

All requests used TLS verification and bounded timeouts from the orb.

| Provider | Boundary | Observed result | Decision |
| --- | --- | --- | --- |
| Picturehouse | GET `https://www.picturehouses.com/cinema`, venue and `/information` pages | HTTP 200, 25 venues discovered | Fresh HTML discovery adapter |
| Picturehouse | POST `https://www.picturehouses.com/api/get-movies-ajax`, `start_date=show_all_dates&cinema_id=019&filters=` | HTTP 200 successful JSON; sessions span all venues even when a cinema ID is supplied | Filter sessions by numeric `CinemaId`; interpret `Showtime` in London |
| Cineworld | GET `https://www.cineworld.co.uk/api/cinema/list?full=true&key=ios&territory=GB`, detail, dates, film lists and performances | HTTP 403 Cloudflare challenge | Disabled; access failure, parser compatibility unknown |
| Odeon | POST `https://api.odeon.co.uk/2.1/api/all-cinemas`, `app-init`, `film-times` | DNS resolution failure (curl 6, HTTP 000); public website returned 403 | Disabled; legacy API viability unverified |

Do not interpret blocked requests as proof a provider cannot work from another
environment. Establish supported access/current endpoints before implementing the
other adapters. The old Picturehouse parser demonstrably assigned cross-venue
sessions to the requested venue and assumed UTC for local UK times. It is not a
trustworthy side-by-side baseline; representative payloads and independently
calculated BST expectations are covered by replacement tests.

## Explicit product choices

- London midnight calendar days; no dead-code 06:00 rule.
- Current/future showings determine visibility; cleanup every 10 minutes updates counters.
- Hidden films are absent from all public reads; events/no-match films remain visible.
- Public IDs are immutable app tokens, with decorative canonical suffixes.
- Title aliases normalise Unicode, case, punctuation and whitespace; uncertain
  title collisions/remakes are triaged rather than claiming universal film matching.
- Uploaded images or trusted TMDB URLs replace arbitrary server-side URL fetches.
- No production data migration is attempted without an export and backup.

## Before switching traffic

1. Inspect production access logs and identify v1 consumers. This checkout has no
   traffic evidence: consumer absence is **not** established. Capture their real
   responses and arrange a transition to `/api`, or keep the old app serving them.
2. Decide whether to migrate curated films, aliases and historical IDs. With a
   PostgreSQL export, check orphan counts and deduplicate before loading SQLite;
   preserve legacy UUIDs as scoped external identifiers if redirects are required.
   Recalculate counters. Do not trust old counters or name-derived slugs.
3. Verify source image availability/ownership and migrate or regenerate assets.
   Rotation of old signing, storage and service credentials is still required.
4. Validate multiple cinemas across providers and midnight/BST dates. Picturehouse
   is the implemented vertical slice; Cineworld/Odeon must not be advertised as imported.
5. Provision real operators, mail delivery, TMDB credentials, domain/registry/hosts,
   persistent storage and tested backup/restore. No default login or live service
   credentials are checked in. Live TMDB enrichment needs credentials; tests use fixtures.
6. Run CI and review the local replacement, then explicitly authorize shipping and
   deployment. Enable Dependabot auto-merge only behind required green CI checks.
