# At The Movies: notes for agents

## The production database is a cache

The importers can rebuild everything from the chain gems and TMDB, so
production has no backups. A rebuild is the recovery plan: see chunk 8 of
`docs/runbooks/deploy-to-hatchbox.md`.

Keep it that way:

- Fix bad data at its source. Film titles go in the `cinebase` title
  sanitizers or the chain gem, so TMDB's first search result is the right
  film. Cinema names, addresses and coordinates go in the chain gem. A
  database edit alone is lost on the next rebuild.
- A manual TMDB pick, alias or merge is a sanitizer bug. Fix the gem so the
  import gets it right on its own.
- Text an operator writes by hand (overview, tagline, runtime) is logged and
  exported as CSV, not backed up (#746).
- Some loss on rebuild is accepted: `hidden` and `event` flags, uploaded
  posters and backdrops, and operator accounts. Uploads are mostly for
  one-off events and other non-films, whose showings pass within weeks.

Don't propose backups, or a fix that lives only in the database. Propose the
gem change.

## Production access

Agents don't SSH into the production server. Write the exact command for
Andy to run, and read the output he pastes. Batch read-only checks into one
command.
