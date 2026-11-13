# Development

## Local prerequisites
Node.js 24, pnpm 10.20.0, and PostgreSQL 18. Copy `apps/api/.env.example` values into the ignored repository-root `.env.local`, then set local credentials for a dedicated `auray_dev` role/database and a separate disposable `auray_test` database. Do not point integration tests at a shared or production database. The test harness requires a local `auray_test` target and clears its application tables before each run.

## Start applications

```bash
pnpm install --frozen-lockfile
pnpm dev
pnpm --filter @auray/storefront dev  # http://localhost:3000
pnpm --filter @auray/admin dev       # http://localhost:3001
pnpm --filter @auray/api dev         # http://localhost:4000/health
```

`pnpm dev` runs all three independently deployable applications. All current routes are starter placeholders.

## Verification

```bash
pnpm verify:workspace
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

Use `pnpm --filter @auray/<app> <command>` for a focused check. GitHub Actions runs independent checks with the committed frozen pnpm lockfile. The scaffold tests cover simple route/page output, not commerce or security features.

## Styling

Both standalone Next.js apps use **Tailwind CSS v4.3.4**, with the official `@tailwindcss/postcss` integration and local `postcss.config.mjs` files. Their global styles import `tailwindcss`, and Tailwind utility classes are the default styling approach. Keep brand tokens and shared visual conventions pending approved Auray branding; use custom CSS only when justified.

## Environments
Only sanitized `.env.example` files belong in Git. The API's Drizzle config reads `DATABASE_URL` from the ignored repository-root `.env.local`. Generate migrations from the schema and review their SQL before applying them:

```bash
pnpm --filter @auray/api db:generate -- --name describe_change
pnpm --filter @auray/api db:migrate
pnpm --filter @auray/api test
```

`db:migrate` applies checked-in migrations to the configured `DATABASE_URL`; it is a manual developer command and never runs on API startup. The integration test applies migrations twice to verify repeatability and enforces that its target is the local `auray_test` database. Drizzle migrations are forward-only: before a production migration, take and verify a database backup; recovery means restoring that backup into a separate database, validating it, and switching the application only through the deployment runbook. Do not use destructive reverse SQL against live commerce records.

## Git workflow
Follow the branch naming, review, and merge rules in the root [`AGENTS.md`](../AGENTS.md). `main` is the only permanent branch; run and report the relevant real checks before requesting review.

## Dependency policy
Use Node 24 and pnpm 10.20.0. Update and commit the root `pnpm-lock.yaml` whenever a dependency changes. CI uses `pnpm install --frozen-lockfile`. Pin GitHub Actions to full reviewed commit SHAs.

## Database testing when implemented
Use real PostgreSQL for Drizzle migration/inventory/payment concurrency tests. Document the target DB, backup and rollback plan before production migrations. This scaffold does not claim those tests have been implemented.
