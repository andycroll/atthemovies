# Deploying At The Movies to Hatchbox

How `movies.andycroll.com` gets from `master` to the shared Hetzner box behind
Cloudflare. It is the same stack as btnbuses, wbrdash and usingrails: one
server, SQLite, jobs in Puma, Caddy for TLS, Postmark for mail.

This is a fresh start. There is no data or image migration from the old app,
and no v1 API consumers to move. All listings come from the importers.

Steps marked **[Andy]** need an account, a secret or DNS access. Everything
else can be done by anyone with SSH to the box.

| Layer | Choice |
|---|---|
| Server | Existing Hetzner box shared with btnbuses, usingrails and wbrdash (Ubuntu, glibc), roles Web + Cron + DB |
| Deploys | Hatchbox: `git pull`, `bundle`, `assets:precompile`, `db:migrate`, restart. Auto-deploy on push to `master` |
| Proxy + TLS | Caddy (Hatchbox-managed), Let's Encrypt |
| App server | Puma single mode, Solid Queue as a child (`SOLID_QUEUE_IN_PUMA`) |
| Database | Four SQLite files in `storage/`, symlinked to `shared/storage/` |
| Uploads | Active Storage `local` service, also in `storage/` |
| Edge | Cloudflare proxy on the `andycroll.com` zone |
| Mail | Postmark SMTP, for password reset only |
| Backups | None at launch, like btnbuses. Gate before curation starts: see chunk 8 |
| Observability | Hatchbox logs and an uptime monitor on `/up`. AppSignal is a follow-up |

---

## Chunk 1: What the repo already does

**What.** Production config that reads the host from the environment, forces
HTTPS behind Caddy, and sends mail through Postmark.

**Why.** Hatchbox runs the app as plain Puma on the box. Nothing is baked into
an image, so host-specific values come from the Hatchbox environment.

| File | State |
|---|---|
| `config/environments/production.rb` | `assume_ssl` and `force_ssl` on. `APP_HOST` sets mailer links. `APP_HOSTS` fills `config.hosts`. `/up` skips the host check. Postmark SMTP with the token from credentials |
| `app/mailers/application_mailer.rb` | Sends as `At The Movies <hello@movies.andycroll.com>` |
| `config/database.yml` | Production `primary`, `cache`, `queue` and `cable` live in `storage/` |
| `config/storage.yml` | `local` Disk service at `storage/`. Blobs survive deploys with the databases |
| `config/puma.rb` | `plugin :solid_queue` when `SOLID_QUEUE_IN_PUMA` is set |
| `config/recurring.yml` | Production schedule: nightly imports, nightly enrichment, cleanup every 10 minutes |
| `.gitignore` | `config/credentials/*.key` stays out of git |

No `Procfile`. Hatchbox starts Puma, and Puma starts Solid Queue. There is no
separate worker process. The Kamal files are gone; the reference apps do not
use Kamal. `Dockerfile` and `bin/thrust` stay, as in btnbuses and wbrdash.

**Provider binaries.** `cineworld_uk` (and `picturehouse_uk` / `odeon_uk`, if
they are added) ship platform gems with a bundled `curl-impersonate`
executable for glibc Linux x86-64 and ARM64. `Gemfile.lock` lists
`x86_64-linux-gnu` and `aarch64-linux-gnu`, so Bundler picks the right gem on
the box. Two ways this breaks:

- `BUNDLE_FORCE_RUBY_PLATFORM` set on the server or app. Bundler installs the
  source gem, which has no executable. Imports then fail with
  `CineworldUk::AuthenticationError`.
- A musl or non-x86/ARM server. Hatchbox servers are Ubuntu, so this should not
  happen.

Chunk 6 checks both.

---

## Chunk 2: Production credentials **[Andy]**

Production reads `config/credentials/production.yml.enc`, decrypted by
`config/credentials/production.key`. Neither exists yet. The old
`config/credentials.yml.enc` is not used in production and its secrets still
need rotation (see `docs/rebuild-status.md`).

```sh
mise x -- bin/rails credentials:edit --environment production
```

This creates the key and a file with a fresh `secret_key_base`. Add:

```yaml
postmark:
  api_token: <chunk 4>
tmdb:
  access_token: <TMDB → Settings → API → API Read Access Token>
```

The app also reads `TMDB_ACCESS_TOKEN` from the environment. Use one, not both.
Credentials match how the other apps hold service tokens.

1. Put `config/credentials/production.key` in 1Password.
2. Commit `config/credentials/production.yml.enc` on its own branch and merge it.
   The key file never goes in git.

**Gotcha.** The key is the value of `RAILS_MASTER_KEY` in Hatchbox. Pasting
`config/master.key` instead fails the first deploy at `db:migrate` with
`ActiveSupport::MessageEncryptor::InvalidMessage`.

---

## Chunk 3: Create the Hatchbox app **[Andy]**

The server already exists, so this is app setup only.

1. Hatchbox → **Apps → New App**. Name: `atthemovies`. Cluster: the existing
   Hetzner server. The name sets the server paths (`~/atthemovies/`) and the
   unit (`atthemovies-server`).
2. Repository: `andycroll/atthemovies`, branch `master`. Framework: Rails.
3. Auto-deploy: **on**. Every merge to `master` deploys, Dependabot merges
   included.
4. Don't deploy yet.

Check the server still has the **Cron** role (Servers → server → Roles).
Hatchbox runs `db:migrate` only on Cron servers.

Hatchbox symlinks `storage/` to `shared/storage/` on every deploy, so the
SQLite files and Active Storage blobs survive. Nothing to configure.

**Environment tab.** Mark `RAILS_MASTER_KEY` as secret.

```
RAILS_MASTER_KEY=<config/credentials/production.key>
APP_HOST=movies.andycroll.com
APP_HOSTS=movies.andycroll.com
RAILS_LOG_LEVEL=info
RAILS_MAX_THREADS=3
WEB_CONCURRENCY=0
SOLID_QUEUE_IN_PUMA=true
```

Hatchbox sets `RAILS_ENV`. Do not set `BUNDLE_FORCE_RUBY_PLATFORM`.

**Why `WEB_CONCURRENCY=0`.** Puma single mode. One worker means a master plus a
worker, which costs memory for nothing on a box shared by four apps.

**Why jobs in Puma.** SQLite serialises writers per file. A separate worker
process adds no write throughput, only a second thing to restart.

**Deploy Script.** Hatchbox runs `db:migrate`, not `db:prepare`. A fresh app
has no database files, and the cache, queue and cable databases load from
schema files that `db:migrate` never loads. Add this before migrations. It is
idempotent.

```sh
bundle exec rails db:prepare
```

**Server pre-flight.** SSH in and check:

```sh
ssh deploy@<server-ip>
uname -m          # x86_64 or aarch64
ldd --version     # GNU libc, not musl
vips --version    # libvips, for Active Storage image variants
env | grep BUNDLE_FORCE_RUBY_PLATFORM   # nothing
```

If `vips` is missing, install it before the first deploy:
`sudo apt-get install -y libvips42`. btnbuses, wbrdash and usingrails do not
process images, so the box may not have it.

---

## Chunk 4: Transactional mail with Postmark **[Andy]**

**What.** Password reset is the only mail. There is no registration, so an
operator who forgets a password needs this to get back in.

All three must be true before mail leaves:

1. **Domain verified.** Postmark → Sender Signatures → add the domain
   `movies.andycroll.com`. Add its DKIM and Return-Path records to Cloudflare
   DNS as **DNS only (grey)**. Verifying the subdomain keeps the
   `andycroll.com` mail setup untouched.
2. **`from` on that domain.** `ApplicationMailer` sends from
   `hello@movies.andycroll.com`. Postmark rejects anything else.
3. **Server API Token in credentials** as `postmark.api_token` (chunk 2).
   Server token, not account token.

A missing token doesn't stop boot. It fails at send time inside the job, so
the operator sees the reset notice and gets nothing. Look for
`Net::SMTPAuthenticationError` in `bin/rails imports:status` (it lists Solid
Queue failures) or the Hatchbox logs.

---

## Chunk 5: Domain, TLS and Cloudflare **[Andy]**

**Order matters.** Caddy must answer Let's Encrypt's HTTP challenge directly.
Cloudflare's proxy intercepts it. So the record starts grey and goes orange
only after the certificate exists.

1. Cloudflare → `andycroll.com` → SSL/TLS. Check the mode is **Full (strict)**.
   It is zone-wide and btnbuses already runs under it. **Do not change it**
   without checking every other `andycroll.com` host.
2. Cloudflare DNS: note any existing `movies` record and its value. The old app
   is retired, so it points at nothing useful, but keep the value for the
   record.
3. Hatchbox app → **Domains**: add `movies.andycroll.com`.
4. Cloudflare DNS: `A movies` → server IP, **DNS only (grey)**. Replace any old
   `movies` record (A, AAAA or CNAME).
5. Wait for `dig +short movies.andycroll.com` to return the server IP.
6. Trigger issuance: `curl -I http://movies.andycroll.com`. A 308 only proves
   Caddy is listening.
7. Check the issuer:

   ```sh
   openssl s_client -connect movies.andycroll.com:443 -servername movies.andycroll.com </dev/null 2>/dev/null \
     | openssl x509 -noout -issuer -dates
   ```

   You want `O=Let's Encrypt`. `Caddy Local Authority` means the challenge
   failed: orange cloud too early, firewall blocking port 80, or DNS not yet
   propagated. Fix it, then **Deploy Latest** or `sudo systemctl reload caddy`.
8. Flip the record to **Proxied (orange)**.

**Edge follow-up, once live.** Cache rule: bypass `/up`, cache `/assets/*` for
a year.

---

## Chunk 6: First deploy and verification

1. **[Andy]** Hatchbox → **Deploy Latest**. Watch for `bundle install`,
   `db:prepare`, `assets:precompile`, `db:migrate`. Hatchbox installs Ruby
   4.0.7 from `.ruby-version` on the first deploy, as for btnbuses.
2. From your machine:

   ```sh
   curl -i https://movies.andycroll.com/up          # 200
   curl -I http://movies.andycroll.com/             # redirect to https
   ```

3. On the box:

   ```sh
   ssh deploy@<server-ip>
   cd ~/atthemovies/current

   ls -l storage                                   # symlink to ../../shared/storage
   ls ~/atthemovies/shared/storage                 # production.sqlite3, _cache, _queue, _cable

   bundle info cineworld_uk --path                 # ends in -x86_64-linux-gnu or -aarch64-linux-gnu
   bundle exec rails runner 'p Rails.application.config.hosts'   # ["movies.andycroll.com"]
   ps -eo pid,ppid,cmd | grep -E "puma|solid" | grep -v grep
   # solid-queue supervisor's PPID is puma's PID
   ```

4. Cineworld authentication from this box's IP. The provider sits behind
   Cloudflare bot checks, and a datacenter IP may be challenged:

   ```sh
   bundle exec rails runner 'CineworldUk.acquire_token!; puts "token ok"'
   ```

   `CineworldUk::AuthenticationError` here means the nightly Cineworld import
   will fail every night. See "Known risks" below.

---

## Chunk 7: First operator and first imports

**Create the operator. [Andy]** There is no registration. Keep the password
out of shell history: read it inside the console.

```sh
cd ~/atthemovies/current
bundle exec rails console
```

```ruby
require "io/console"
password = IO.console.getpass("Password: ")
User.create!(email_address: "<you>", password: password, password_confirmation: password)
```

Then:

1. Sign in at `https://movies.andycroll.com/session/new`.
2. Sign out and request a password reset. The email arrives and its link
   points at `https://movies.andycroll.com/...`. Postmark → Activity shows it.

**Run the first imports.** The job names live in README → "Imports and
metadata". Run each import job listed there, in the order listed, on the box:

```sh
cd ~/atthemovies/current
bundle exec rails runner '<ImportJob>.perform_later'   # once per import job in README
bundle exec rails imports:status                        # counts, plus any Solid Queue failures
```

`perform_later` hands the job to the Solid Queue worker inside Puma. Watch
`imports:status` until the counts stop growing. Then run the enrichment job
from the same README section the same way, so TMDB metadata fills in.

Check:

- `/`, `/films`, `/cinemas` list real data for today.
- A cinema page shows today's showings in London time.
- `/api/cinemas` returns JSON.
- `/operator/films` lists ambiguous TMDB matches, if any.
- Upload an image on one film. The blob appears under
  `~/atthemovies/shared/storage/` and its variant renders. This proves libvips.

**Next morning.** `bundle exec rails imports:status`: the nightly imports and
enrichment from `config/recurring.yml` ran with no new failures.

---

## Chunk 8: Backups

**At launch: none, by choice.** This is the btnbuses position. On day one all
data comes from the importers, so a lost database is rebuilt:

```sh
systemctl --user stop atthemovies-server
cd ~/atthemovies/shared/storage
broken=broken-$(date -u +%Y%m%dT%H%M%SZ)
mkdir "$broken" && mv production*.sqlite3* "$broken"/
cd ~/atthemovies/current && bundle exec rails db:prepare
systemctl --user start atthemovies-server
curl -i https://movies.andycroll.com/up
```

Units are user units: `systemctl --user`, no `sudo`. Then create the operator
and run the imports again (chunk 7). Uploaded blobs left in `shared/storage/`
no longer have database rows; that is acceptable only while nobody has
uploaded anything.

**Gate: before operators start curating.** Once operators edit films and
cinemas, add aliases, pick TMDB matches, merge films or upload images, that
work cannot be re-imported. Before that starts, add the wbrdash two-layer
backup in a separate PR:

- Litestream in Puma, replicating `production` and `production_queue` to R2.
- A daily `VACUUM INTO` snapshot of the primary to a second R2 bucket, with
  lifecycle rules for retention.
- An off-box copy of the Active Storage blobs in `shared/storage/`. Litestream
  covers SQLite only. usingrails has the same open follow-up.

Follow `wbrdash/docs/runbooks/deploy-to-hatchbox.md`, chunk 6. It needs the
`litestream` gem and new jobs, so it is out of scope for this runbook.

---

## Rollback

- **Bad code.** Hatchbox → Deploys → previous green deploy → Rollback.
- **Bad migration.** `bundle exec rails db:rollback:primary STEP=n` on the box
  first, then roll back the deploy. Plain `db:rollback` raises in a
  four-database app.
- **Bad launch.** **[Andy]** Cloudflare → set the `movies` record back to the
  value noted in chunk 5, or delete it. Nothing else depends on the domain.
- **Bad data.** Rebuild from the importers (chunk 8). Until the backup gate is
  done, this is the only recovery.

---

## Known risks

- **Cineworld from a datacenter IP.** `docs/rebuild-status.md` records a
  Cloudflare 403 from another environment. If chunk 6 step 4 fails, the
  nightly Cineworld entry in `config/recurring.yml` fails every night. Remove
  it in a PR or accept the failures.
- **Visitor IP behind Cloudflare.** The other apps use `cloudflare-rails` so
  `request.remote_ip` is the visitor. Without it, sign-in and password-reset
  rate limits key on Cloudflare's edge IP, and sessions record that IP. With a
  handful of operators this is tolerable. Add the gem as a follow-up.

## Follow-ups (not needed to go live)

- AppSignal: gem, `config/appsignal.rb`, JSON logs and check-ins, as in
  wbrdash chunk 5.
- Backups: the gate in chunk 8.
- `cloudflare-rails`, as above.
- Remove the `kamal` gem from the `Gemfile`.

## Checklist

- [ ] **[Andy]** `production.yml.enc` merged; `production.key` in 1Password and in Hatchbox as `RAILS_MASTER_KEY`
- [ ] **[Andy]** Postmark domain `movies.andycroll.com` verified; token in credentials
- [ ] **[Andy]** TMDB read access token in credentials
- [ ] **[Andy]** Hatchbox app, env vars, `db:prepare` in Deploy Script, Cron role checked
- [ ] Server pre-flight: glibc, x86_64/aarch64, libvips, no `BUNDLE_FORCE_RUBY_PLATFORM`
- [ ] **[Andy]** Domain added, certificate from Let's Encrypt, record orange
- [ ] `/up` 200; HTTP redirects to HTTPS; four SQLite files in `shared/storage`
- [ ] Platform gem selected; Cineworld token acquired from the box
- [ ] **[Andy]** Operator created; password-reset email received
- [ ] First imports and enrichment done; public pages and `/api` show data
- [ ] Image upload renders a variant
- [ ] Next morning: recurring imports ran, no new failures
- [ ] **[Andy]** Uptime monitor on `https://movies.andycroll.com/up`
- [ ] Backup gate done before curation starts
