# Development

## Local prerequisites
Node.js 24, pnpm 10.20.0. PostgreSQL is required when database functionality is added.

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
Only sanitized `.env.example` files belong in Git. Product integrations, Drizzle schema/migrations, R2 and deployment configuration belong to later, separately reviewed changes. Never automatically migrate production on API startup.

## Git workflow
Follow the branch naming, review, and merge rules in the root [`AGENTS.md`](../AGENTS.md). `main` is the only permanent branch; run and report the relevant real checks before requesting review.

## Dependency policy
Use Node 24 and pnpm 10.20.0. Update and commit the root `pnpm-lock.yaml` whenever a dependency changes. CI uses `pnpm install --frozen-lockfile`. Pin GitHub Actions to full reviewed commit SHAs.

## Database testing when implemented
Use real PostgreSQL for Drizzle migration/inventory/payment concurrency tests. Document the target DB, backup and rollback plan before production migrations. This scaffold does not claim those tests have been implemented.
