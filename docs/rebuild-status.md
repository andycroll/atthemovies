# Rebuild status

## Replacement delivered

Generated full-stack Rails 8.1.4 on Ruby 4.0.7 and booted the fresh app before
adding domain code. Applied the daisyUI, CI, Procfile.dev and Dependabot
templates. Retained framework defaults, with a development SQLite queue database
so the Procfile's worker actually runs jobs.

The old application has been removed from the working tree. Historical source
remains in Git history. [REBUILD.md](../REBUILD.md) records what it did.

## Provider checks (31 October 2026)

Each chain's gem was run live through `Chain` from a development machine:
every cinema, and one cinema's future showings.

| Chain | Gem | Cinemas | With coordinates | Advertised dates | Notes |
| --- | --- | --- | --- | --- | --- |
| Arc | `arc_uk` 1.0.0 | 9 (Lewisham not open yet) | 9, from OpenStreetMap | to May 2027 | Admit One A1Web pages through `cinebase/a1web`, no token |
| Cineworld | `cineworld_uk` 4.4.0 | 87 | 87 | to June 2027 | Vista OCAPI, guest token |
| Curzon | `curzon_uk` 1.1.0 | 14 | 14 | to December 2026 | Vista OCAPI, guest token, coded site ids such as SOH1 |
| Depot, Lewes | `depot_uk` 1.0.1 | 1 | 1 | to May 2027 | Jacro WordPress calendar, 5 requests; films only; brand Independent |
| Everyman | `everyman_uk` 1.0.0 | 49 | 49 | to May 2027 | Boxoffice routes through `cinebase/boxoffice`, no token |
| Glasgow Film Theatre | `gft_uk` 1.0.1 | 1 | 1 | to February 2027 | Indy GraphQL API, about 6 requests; brand Independent |
| Merlin | `merlin_uk` 1.0.1 | 22 | 22 (3 from postcodes) | to May 2027 | Each cinema's home page, 1 request; Admit One booking; live stage shows left out |
| Movie House | `moviehouse_uk` 1.0.1 | 4 (Northern Ireland) | 4, from OpenStreetMap | about four weeks ahead | Admit One A1Web pages through `cinebase/a1web`, no token |
| ODEON | `odeon_uk` 5.2.0 | 101 | 101 | to April 2027 | Vista OCAPI, guest token, no postcodes in the API, UK only |
| Light | `light_uk` 1.0.1 | 14 | none on the website | to May 2027 | Glitterfish site, no token; fortnight guide plus coming soon page; certificate needs Sectigo Root R46 |
| Omniplex | `omniplex_uk` 1.0.1 | 22 (8 GB, 14 NI; not ROI) | 22 | to May 2027 (most NI to December) | Admit One with Omniplex's own pages, one day per page, about 1,070 requests a night |
| Picturehouse | `picturehouse_uk` 6.1.0 | 25 | 24 (not Chester) | to June 2027 | Vista OCAPI, guest token |
| Prince Charles Cinema | `princecharles_uk` 1.0.1 | 1 | 1 | to June 2027 | Jacro WordPress site, whole programme on one page; TapOS ticketing; brand Independent |
| Reel | `reel_uk` 1.0.1 | 16 | 16 (Burnley from its postcode) | to May 2027 (A1Web venues to December) | 13 venues on a Jacro WordPress site, one request per film; Hull, Morecambe, Quinton on A1Web; TapOS ticketing |
| Rio, Dalston | `rio_uk` 1.0.1 | 1 | 1 | to January 2027 | Savoy what's on page, 1 request; titles put in title case; brand Independent |
| Scott | `scott_uk` 1.0.1 | 6 | 6 | to May 2027 | Scott's own JSON feed per venue; TapOS ticketing |
| Showcase | `showcase_uk` 1.0.0 | 16 | 16 | to May 2027 | Boxoffice routes through `cinebase/boxoffice`, no token; Bluewater has about 1,500 future showings |
| Spektrix independents | `spektrix_uk` 1.0.1 | 5 | 5 | to June 2027 | Spektrix API v3, no token; Broadway, HOME, Hyde Park Picture House, Showroom, Tyneside; coordinates from OpenStreetMap |
| Vue | `vue_uk` 1.1.0 | 88 | from each cinema page | to May 2027 | myvue.com API, no token, UK only |
| Watershed, Bristol | `watershed_uk` 1.0.1 | 1 | 1 | to May 2027 | Ticketsolve XML feed, 1 request; brand Independent |
| WTW | `wtw_uk` 1.0.1 | 4 (Cornwall) | 4 | to May 2027 | Jacro WordPress site, 1 request per cinema; showtimes already started today have no booking link |

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
