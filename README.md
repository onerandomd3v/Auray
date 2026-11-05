# Auray

Fashion-commerce platform developed by CodedDevs Technology LTD.

## Applications
- `apps/web/storefront` — independent Next.js public storefront (port 3000)
- `apps/web/admin` — independent Next.js owner dashboard (port 3001)
- `apps/api` — NestJS REST API (port 4000)

This PR provides **runnable application scaffolds**, not e-commerce functionality. No products, payments, emails, sessions, persistence or deployments have been implemented.

## Local development

Node.js 24 and pnpm 10.20.0:

```bash
pnpm install --frozen-lockfile
pnpm dev
# individually:
pnpm --filter @auray/storefront dev
pnpm --filter @auray/admin dev
pnpm --filter @auray/api dev
```

## Verification

```bash
pnpm verify:workspace
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

CI runs independently for Workspace, Storefront, Admin and API. See `docs/development.md`, `docs/architecture.md` and `AGENTS.md`. Only `main` is a permanent branch. No Linear issues during the bootstrap.
