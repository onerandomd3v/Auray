# Auray

Fashion-commerce platform developed by CodedDevs Technology LTD.

## Applications
- `apps/web/storefront` — independent Next.js public storefront (port 3000)
- `apps/web/admin` — independent Next.js owner dashboard (port 3001)
- `apps/api` — NestJS REST API (port 4000)

**Project decisions are approved; implementation is underway.** The repository currently contains runnable application scaffolds, not the completed commerce functionality. Products, payments, transactional emails, sessions, persistence and deployment are not yet implemented. This status does not mean the corresponding architecture is awaiting approval.

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

CI runs independently for Workspace, Storefront, Admin and API. Read [approved product requirements](docs/product-requirements.md), [architecture](docs/architecture.md), [engineering decisions](docs/decisions.md), [implementation handoff](docs/implementation-readiness.md), [development](docs/development.md) and [agent instructions](AGENTS.md) before working.

`main` is the only permanent branch. Short-lived PR branches must follow the naming standard in `AGENTS.md`; no `codex/` branches. Issue tracking happens through assigned Linear work when authorized.
