# Development standard

## Repository status
This is a **documentation and policy bootstrap**. The Next.js/NestJS apps, root package manifest, pnpm lockfile, Drizzle migrations and deployment compose files are not yet generated. The first application-scaffold PR must add them and replace bootstrap-only CI validation with genuine app lint, typecheck, tests and builds. Do not report bootstrap CI as application verification.

## Environment target
- Node.js 24 (use the appropriate 24.x release supported by your selected framework tooling).
- pnpm workspaces; one shared root lockfile when applications are initialized.
- Local PostgreSQL for database feature tests.
- Three distinct application env configurations; commit only `.env.example` templates with no secrets.

## Planned commands after scaffold
```bash
corepack enable
pnpm install --frozen-lockfile
pnpm --filter @auray/storefront dev
pnpm --filter @auray/admin dev
pnpm --filter @auray/api dev
pnpm format:check
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```
These are **planned**, not current runnable commands.

## Git and pull requests
1. Fetch latest `main`; create focused branch, preferably `feat/...`, `fix/...` or `chore/...`.
2. Read root and scoped `AGENTS.md`, architecture/decisions and the task specification.
3. Work in a separate worktree if multiple agents/tasks are active.
4. Change only necessary files; update tests/docs, review migrations and security implications.
5. Run and record actual checks; open PR against `main` with a clear summary/evidence.
6. Bring branch up to date with latest `main` before merging; require green independent Workspace, Storefront, Admin and API checks once apps exist.
7. Resolve review conversations; squash-merge. Never push directly to protected `main`, create `dev`, or auto-merge.

## Database
Generate SQL migrations through Drizzle Kit, commit reviewed SQL, apply migrations through an explicit release step, never automatic app startup. Confirm database target and backup before production change. Use Postgres transactions for inventory/payment state.

## Engineering verification expectations
- Financial/security/inventory changes: real DB integration tests, webhook fixtures, duplicates/out-of-order and race conditions.
- Frontends: accessibility and checkout/owner flow tests.
- Contract changes: update shared schemas and both consumers.
- Keep provider credentials out of Git. Never substitute live payment tests for Bachs sandbox.
