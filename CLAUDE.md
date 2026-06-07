# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **⚠️ This repo is public (github.com/sudara/alonetone).** This file is committed and world-readable. Do not add secrets, private URLs, internal-only hostnames, customer data, unpublished security details, or anything else that shouldn't live on the open internet. Treat it like a README.

## Stack

Rails 8.1 on Ruby 4.0, MySQL, Sidekiq, Active Storage (S3 in prod, local in dev), Hotwire Turbo + Stimulus 3, Propshaft + jsbundling-rails (esbuild) for assets, dartsass-rails for SCSS with a dark/light theme system. Audio playback uses the custom `@alonetone/stitches` library. Auth is Authlogic (with scrypt); spam detection is Rakismet (Akismet).

## Development commands

```bash
rails setup              # copies *.example.yml configs, touches JS stubs, runs db:setup
bin/dev                  # boot server (Rails + esbuild watch + dart-sass via foreman)
bundle exec guard start  # watch-mode RSpec — runs the matching spec when a file changes
bundle exec rspec spec/features/home_page_spec.rb  # run a single spec
bundle exec rspec --exclude-pattern "spec/features/**/*_spec.rb"  # fast, non-browser suite
bundle exec rubocop      # linter (rules in .rubocop.yml — loose: Metrics/* bumped to 500)
bundle exec rails db:reset  # reset DB and reload seeds (programmatic, not a dump)
```

Seed logins: `owner`, `moderator`, `musician`, `marieh`, `carole`, `petere`; password `testing123` for all.

Feature specs run in headless chromium via Playwright (`capybara-playwright-driver`), registered as `Capybara.default_driver = :alonetone` in `spec/rails_helper.rb`. Run `HEADED=1 bundle exec rspec spec/features/...` to watch the browser. The `playwright` npm package and `npx playwright install chromium` are required dev dependencies. Fixtures are global (`config.global_fixtures = :all`) and fixtures + support helpers get auto-included.

CI runs two jobs in parallel: "Normal Specs" (everything except `spec/features`) and "Feature Specs & Percy" (features with visual-regression snapshots via `npx percy exec`). Percy requires `PERCY_TOKEN`.

## Domain vocabulary (has historical baggage)

- **Asset** = an mp3 (audio track). The model is the hot center of the app.
- **Track** = a join between an `Asset` and a `Playlist` (the join row, not the audio).
- **Playlist** = either an album (`is_mix: false`) or a mix (`is_mix: true`). Every user has exactly one `is_favorite: true` playlist that gets appended to when they "heart" something.
- **Home page** routes to `assets#latest`.
- Many views live in `app/views/shared/` — more than ideal.

## Architecture

**Routing shape.** `config/routes.rb` mounts most user-facing URLs *under the user's login slug* — `/:login/tracks/:id`, `/:login/playlists/:id`, `/:login/history`, `/:login/comments`, `/:login/toggle-follow`. This means `find_user` / `find_asset` in `ApplicationController` resolve records by slug (`login`, `permalink`) rather than numeric ID. The `Slugs` concern (`app/models/concerns/slugs.rb`) auto-generates unique slugs scoped per-user. `/admin/*` is a separate namespace for moderation.

**Soft deletion is pervasive.** The `SoftDeletion` concern (`app/models/concerns/soft_deletion.rb`) adds a `default_scope` that hides `deleted_at IS NOT NULL` rows — so queries silently exclude soft-deleted records unless you call `.with_deleted` or `.only_deleted`. `Asset`, `User`, `Playlist` all include it. Records destroyable after 30 days via cron (`destroy_deleted_accounts_older_than_30_days`). 404 handlers in `ApplicationController` explicitly check `with_deleted` to give friendlier "recently deleted" messages.

**Spam & abuse.** `Rakismet::Model` is mixed into `User`, `Asset`, and `Comment` with different `comment_type` values (`signup`, `mp3-post`, `comment`). The admin controllers expose `spam`/`unspam` member actions. `PreventAbuse` controller concern and a rudimentary banned-words list force-mark submissions as spam. IP-based spam sweeps: `Admin::UsersController#mark_all_users_with_ip_as_spam` + `MarkAllUsersWithIpAsSpam` job.

**Storage abstraction.** `app/models/storage/` wraps Active Storage URL generation. `Storage::Location` picks between direct S3, signed CloudFront (for originals), or Fastly (for image variants) based on `Rails.application.fastly_enabled?` / `cloudfront_enabled?` / `remote_storage?` predicates defined in `config/application.rb`. Treat `Location#url` as a lazy promise — views may evaluate late. Variant processing uses libvips (`config.active_storage.variant_processor = :vips`); analyzers and previewers are disabled.

**Uploads.** `Upload` (service object, `app/models/upload.rb`) accepts an array of `ActionDispatch::Http::UploadedFile`s, dispatches each to `Upload::Mp3File` or `Upload::ZipFile` based on mime type (shells out to `file --mime-type`), and builds `Asset` + `Playlist` records in batch. Import is best-effort: it saves whatever parsed successfully and surfaces the rest as validation errors. Audio validation is enforced on `Asset#audio_file` (<60 MB, `audio/mpeg|mp3|x-mp3`).

**Background jobs** (Sidekiq, `app/jobs/`): `WaveformExtractJob` runs `audiowaveform` after `Asset` creation (requires `brew install audiowaveform`); `CreateAudioFeatureJob` lazily generates audio features on playback; `AssetNotificationJob` / `AlbumNotificationJob` email followers on publish; `MarkAllUsersWithIpAsSpam` is a moderation tool.

**Controller concerns** (`app/controllers/concerns/`): `Authentication` (Authlogic integration), `Authorization` (`admin?`, `moderator?`, `require_login`, `admin_only`, `moderator_only`), `Listens` (play tracking), `PreventAbuse`, `UserCreation`. `ApplicationController` includes all of these plus `Pagy::Backend` and etag-keys the current user's id+theme.

**Model splitting pattern.** Large models are split into mixin modules co-located in a subdirectory: `Asset::Radio`, `Asset::Statistics`, `Asset::Waveform` live under `app/models/asset/`; `User::Findability`, `User::Statistics` under `app/models/user/`. When adding non-trivial behavior to a big model, consider a new concern there instead of bloating the base file.

**Service/command objects.** `AssetCommand` and `UserCommand` (`app/commands/`) own multi-step destroy flows — `User#destroy_with_relations` delegates to `UserCommand#destroy_with_relations` to avoid Active Record callback ordering pitfalls. Pattern to follow for cross-model mutations.

**Frontend.** Stimulus controllers under `app/javascript/controllers/` (e.g., `playback_controller.js`, `playlist_sort_controller.js`) are wired up automatically. `app/javascript/animation/MorphSVGPlugin.js` is a stub file that `rails setup:touch_js` creates; CI injects a real license via the `MORPHSVG` secret. Turbo handles navigation; avoid full-page reloads where a Turbo Frame/Stream will do.

## Performance

alonetone is 15 years old and has survived 7 major Rails upgrades. Some tables (assets, listens, comments) have grown for over a decade. Performance is not a "nice to have" here — it's load-bearing. Pay closer attention than you would on a fresh app:

- **N+1s.** Use eager loading (`includes`, `preload`, `eager_load`) deliberately. The big models have curated preload scopes (e.g., `Asset.with_preloads`, `Playlist.with_preloads`) — prefer those over inventing fresh `includes` calls. When adding a view that iterates records, tail `log/development.log` and grep for repeated queries on the same table before shipping. Consider adding the `bullet` gem if working on a known-hot path.
- **Indexes.** New scopes, `where` clauses, or `order` columns on hot tables should map to an existing index. Check `db/schema.rb` before writing the query. If no index covers it, add a migration — composite indexes need to match column order in the `WHERE` + `ORDER BY` to be used. Don't add an index speculatively, but don't ship an unindexed query on `assets` / `listens` / `comments` either.
- **Counter caches over `COUNT(*)`.** Many `_count` columns already exist (`tracks_count`, `listens_count`, `assets_count`, etc.) — use them. Adding `belongs_to :foo, counter_cache: true` requires a backfill migration; don't forget the backfill.
- **Pagination is mandatory** on any list of user-generated content. We use `pagy` — see `Pagy::Backend` in `ApplicationController`. Don't `.all` or `.limit(big_number)` on hot tables.
- **Watch for the soft-deletion default scope** — it adds a `deleted_at IS NULL` predicate to every query on `Asset`/`User`/`Playlist`. Index plans should include `deleted_at` when relevant.

## Testing

- **Red-green when changing behavior.** When fixing a bug or changing observable behavior, write the test first, run it and watch it fail, then make it pass. The failing run is the proof the test actually exercises the thing you're changing — skip it and you'll ship tests that pass against any implementation.
- **Coverage on review.** When reviewing a diff, any significant change to a model or controller should come with tests. If it doesn't, flag it. "Significant" = new public method, changed branching/conditions, new validation/callback/scope, new controller action or altered response — not pure renames or formatting.

## CSS conventions (see CONTRIBUTING.md for the full version)

- Split by **component/page** — new page gets a new file; reusable extractions only when actually shared.
- Selectors scoped to a top-level class (e.g., `.hero`); not meant to be reusable outside their file's context.
- **All colors must be variables** — two themes (`dark.scss`, `white.scss`) both bind the same variable names to different hex values. Hex values are declared exactly once in `color_mapping.scss`, names synced with the Figma file. When adding a color, make a new descriptive variable (e.g., `$view-all-background`) defined in *both* theme files, grouped by the consumer's filename.

## Conventions worth knowing

- `frozen_string_literal: true` is intentionally disabled in Rubocop — don't bother adding magic comments.
- Annotations at the bottom of model files are generated by the `annotaterb` gem; `.annotaterb.yml` controls it and `lib/tasks/annotate_rb.rake` wires it into `db:migrate`.
- Seed data is programmatic (`db/seeds.rb`) — we don't use prod dumps locally.
- `secretz` route (`admin#secretz`) and `sudo` action on `users` exist for admin debugging — they're not typos.
- **Gemfile comments exist for one reason only: explaining a real version pin.** A real pin is something that actually blocks an upgrade: `= x.y.z`, `~> x.y.z`, `< x.y.z`, or a tight range. Those MUST have a comment on the line above explaining *why* (upstream bug, incompatibility, waiting on a PR, etc.). A bare `>=` floor is NOT a pin — bundler won't downgrade past what's already locked, so it constrains nothing and should not be commented (just drop it). Conversely, do not add commentary to non-pinned gem lines — no rationale for adding a gem, no migration notes, no "what this is for." Keep the Gemfile lean.


## Answering style

Lead with the direct answer to what was asked — a single sentence or number, not preamble. Detail, breakdown, and caveats come *after* the clear answer, never before it. If the user asked "how much?", the first line is the number.

## Commit and comment style

**Commits.** One-line subject describing what changed, imperative voice (e.g. "Fix race in home page track ordering", "Cap a single user to 2 tracks/playlists on the home page"). Add at most 1-2 lines of body when the *why* isn't obvious from the diff. No multi-paragraph bodies. No `Co-Authored-By` trailer. When the working tree has multiple unrelated changes, split them into logically grouped commits — don't lump independent work into one.

**Stashing.** Only stash files you touched. The working tree may contain unrelated edits from the user or another agent — `git stash` with no pathspec sweeps those up too. Use `git stash push -- <paths>` to scope it, and check `git status` first so you know what's yours.

**Comments.** Default to none — the best comment is no comment. When you do write one: one line, explaining *why* (a hidden constraint, a workaround, a surprise), not *what*. Multi-line comments are a code smell. Do NOT touch existing multi-line comments that are still accurate — they were written deliberately; rewording them is just churn. Only modify a comment if the code it describes has changed.

## Deployment context

This repo runs one site (alonetone.com) — it is open-source as an educational example, **not** a white-label solution. Don't add generalization or configurability for hypothetical reuse.

**How deploys actually happen.** There is no Capistrano / Kamal / `deploy.rb`. The deploy is a bash script at the repo root: `./deploy` (with `--force-bundle` to force `bundle install` + a full Puma restart). It ssh's to the `alonetone` host, fast-forwards to `origin/main` under `/data/alonetone`, conditionally runs `bundle install` / `yarn install` / `db:migrate` / `assets:precompile` based on what changed, phased-restarts Puma (full restart if Puma or Ruby version moved), bounces Sidekiq, and pings Bugsnag's build endpoint with the new revision. Post-deploy hooks (release markers for Bugsnag/New Relic/etc.) live in the local `curl` block at the bottom of the script — mirror the Bugsnag block when adding another.

## Database tuning (Percona 8.0 on prod)

Production runs Percona Server 8.0 on Ubuntu with a custom tuning file at `/etc/mysql/mysql.conf.d/zz-tuning.cnf` (loads last so its values win). It overrides the otherwise-stock defaults with: `innodb_buffer_pool_size = 2G`, `innodb_redo_log_capacity = 512M`, slow query log on at `long_query_time = 1.0` writing to `/var/log/mysql/slow.log`, and `tmp_table_size = max_heap_table_size = 64M`. Budget ~4 GB RSS for mysqld with these settings.

**Revisit when moving servers.** The buffer pool sizing assumes ~15 GB RAM shared with Rails/Sidekiq/Redis/Docker-Postgres. On a smaller box, scale `innodb_buffer_pool_size` down (rough rule: ~1 GB on a shared 4 GB host, ~2 GB on a shared 8 GB host) and re-check `max_connections` against the new Puma/Sidekiq pool math.
