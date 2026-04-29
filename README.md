# routebox-ops-console

Internal admin console for Routebox operators (customer support, billing, ops). Rails 6. Owns the shared Postgres database — though "owns" is increasingly aspirational.

> Read [`routebox-platform-docs`](https://github.com/312school/routebox-platform-docs) first if you haven't.

## What this app does

- Internal-only web UI for ops staff (not exposed to customers)
- Account management — create/edit tenants, manage users, set plan tiers
- Billing — invoice generation, manual adjustments, refund flow
- Shipment ops view — search, intervene on stuck shipments, kick off retries
- Customer-support tooling — impersonation, audit trails, support tickets

## Repo layout

```
.
├── app/
│   ├── controllers/
│   ├── models/
│   ├── views/
│   └── ...
├── config/
├── db/
│   ├── migrate/             # Rails-native migrations — see notes
│   └── schema.rb
├── lib/
├── test/
├── Dockerfile
├── docker-compose.yml
├── Jenkinsfile
├── Gemfile
├── Gemfile.lock
└── README.md
```

## Database — read this carefully

This service was historically the *only* writer to the shared Postgres. As `shipments-api`, `tracking-events`, and (read-only) `route-optimizer` came online, that stopped being true, but the historical assumption is baked into the codebase. There are still controllers that assume "if this row exists, ops-console wrote it" — sometimes that's wrong.

### Migrations

Database migrations are **partially in this repo, partially in [`routebox-db-migrations`](https://github.com/312school/routebox-db-migrations)** (Flyway). The ongoing migration of all schema changes to the standalone Flyway repo is incomplete.

Today: `db/migrate/` here still contains active Rails migrations that ship with each `ops-console` deploy. They run via `bundle exec rails db:migrate` in the deploy pipeline. Some are coordinated with Flyway migrations in the dedicated repo. Some are not. There has been at least one production incident caused by ordering ambiguity between the two.

**If you're adding a schema change, the rule is "use Flyway."** In practice, half the time someone reaches for a `rails generate migration` and adds it here instead. Be the change.

### The migration gem

This app uses a **third-party migration gem** (`strong_migrations`) that the original author of the codebase pinned to an old version. The gem is now effectively unmaintained — its repo hasn't seen a meaningful release in a couple of years. Upgrading it requires picking a successor (either staying on a fork, or moving to a different safety-rails approach), which is tied up with the broader Rails-to-Flyway migration story.

We are pinned to a version that has known issues with newer Postgres versions. We have not hit them. We will, eventually.

## Running locally

```
docker compose up
```

Brings up Postgres, Redis (Sidekiq for background jobs), and the Rails app on `localhost:3001`. Database gets seeded with a small set of test fixtures on first run.

The compose file is up to date as of last check. The seed data is not — it predates the introduction of multi-tenant routing in Rails, so some pages 500 on the seeded data unless you create a tenant first via the seed rake task (`bundle exec rake routebox:dev_seed_tenant`).

## Deploys

`Jenkinsfile` uses the [`routebox-jenkins`](https://github.com/312school/routebox-jenkins) shared library. Build, push to ECR, deploy to ECS. The deploy pipeline includes a `bundle exec rails db:migrate` step that runs after the deploy to apply any new Rails-native migrations. This step **can race** with Flyway migrations applied separately. We've talked about a coordinated migration pipeline. It hasn't happened.

## Configuration

Standard Rails — environment variables via `config/`. Notable ones:

- `DATABASE_URL` — Postgres connection (Secrets Manager → env var)
- `REDIS_URL` — for Sidekiq
- `SECRET_KEY_BASE` — pulled from Secrets Manager
- `ROUTEBOX_INTERNAL_API_TOKEN` — for calls to `shipments-api`'s internal endpoints

## Background jobs

Sidekiq. Notable jobs:

- `BillingReconciliationJob` — runs nightly, reconciles `tracking-events`-derived shipment events against billing
- `WarehouseSyncJob` — runs nightly, calls `shipments-api`'s `/internal/legacy-export` and pushes to the data warehouse
- `TenantUsageRollupJob` — runs hourly

The `WarehouseSyncJob` is the customer of the undocumented endpoint mentioned in `routebox-shipments-api`'s README. If you remove that endpoint, this job breaks.

## Known issues

- Rails-native migrations vs. Flyway split (above)
- Unmaintained `strong_migrations` pin (above)
- Some controllers assume sole-writer to the DB (above)
- Sidekiq is on a single node; if it dies, jobs back up. Multiple-node Sidekiq is a TODO.
- Test suite is slow (~6 minutes). Half the time is Rails boot. We've discussed Spring/Bootsnap tuning.
- The impersonation feature has gaps — an admin who impersonates a user can read but not always write as them, and it's inconsistent which controllers respect impersonation.

For broader context, read [`routebox-platform-docs/notes/handover.md`](https://github.com/312school/routebox-platform-docs/blob/main/notes/handover.md).
