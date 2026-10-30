# Rebuild status

## Replacement delivered

Generated full-stack Rails 8.1.4 on Ruby 4.0.7 and booted the fresh app before
adding domain code. Applied the daisyUI, CI, Procfile.dev and Dependabot
templates. Retained framework defaults, with a development SQLite queue database
so the Procfile's worker actually runs jobs.

The old application has been removed from the working tree. Historical source
remains in Git history. [REBUILD.md](../REBUILD.md) records what it did.

## Provider checks (30 October 2026)

Each chain's gem was run live against one cinema through `Chain`, from a
development machine.

| Chain | Gem | Cinemas | Advertised dates | Notes |
| --- | --- | --- | --- | --- |
| Cineworld | `cineworld_uk` 4.3.2 | 87 | to June 2027 | Vista OCAPI, guest token |
| Curzon | `curzon_uk` 1.0.0 | 14 | to December 2026 | Vista OCAPI, guest token, coded site ids such as SOH1 |
| Everyman | `everyman_uk` 1.0.0, in `vendor/gems` | 49 | to December 2026 | Boxoffice routes on everymancinema.com, no token, postcodes and coordinates |
| ODEON | `odeon_uk` 5.1.1 | 101 | to April 2027 | Vista OCAPI, guest token, no postcodes, UK only |
| Picturehouse | `picturehouse_uk` 6.0.1 | 25 | to June 2027 | Vista OCAPI, guest token |
| Vue | `vue_uk` 1.0.0 | 88 | to May 2027 | myvue.com API, no token, UK only |

The four Vista gems bundle `curl-impersonate` for glibc Linux (x86-64, ARM64)
and macOS. Production must run on one of those platforms.

## Decisions

- Nobody consumes the legacy v1 API. Its JSON:API contract is not retained and
  needs no transition; `/api` replaces it.
- No data migration. Cinemas, films and performances come from fresh imports.
  Legacy UUIDs, curated titles and aliases are not carried over.
- No image migration. Posters and backdrops come from TMDB enrichment.
- London midnight calendar days; no dead-code 06:00 rule.
- Current/future showings determine visibility; cleanup every 10 minutes updates counters.
- Hidden films are absent from all public reads; events/no-match films remain visible.
- Public IDs are immutable app tokens, with decorative canonical suffixes.
- Title aliases normalise Unicode, case, punctuation and whitespace; uncertain
  title collisions/remakes are triaged rather than claiming universal film matching.
- Uploaded images or trusted TMDB URLs replace arbitrary server-side URL fetches.

## Before going live

1. Deploy to movies.andycroll.com on Hatchbox with
   [the runbook](runbooks/deploy-to-hatchbox.md).
2. Provision an operator, mail delivery, the TMDB token, persistent storage and
   tested backup/restore. No default login or live credentials are checked in.
3. Run the first import for each chain and enrichment, then check listings for
   several cinemas across chains and a midnight/BST boundary.
