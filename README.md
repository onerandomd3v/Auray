# Auray

Fashion-commerce platform developed by CodedDevs Technology LTD.

## Applications
- `apps/web/storefront` — independent Next.js public storefront (port 3000)
- `apps/web/admin` — independent Next.js owner dashboard (port 3001)
- `apps/api` — NestJS REST API (port 4000)

## Project status
Product requirements and technical architecture are **approved**. The repository currently contains runnable application scaffolds, not the finished commerce features. Catalogue, inventory, checkout, payments, admin sessions, email integrations, persistence and deployment will be implemented through scoped engineering work. This is implementation status, **not pending architecture approval**.

Bachs and SendByte sandbox behaviour and the client's actual VPS/domain require integration-time verification. Agents must not guess provider capabilities or revisit approved decisions; escalate only a genuine conflict, unavailable external input, or consequential new requirement. The public repository contains non-commercial implementation guidance; signed client contracts remain private.

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

CI runs independently for Workspace, Storefront, Admin and API. Start with [agent instructions](AGENTS.md), [approved product requirements](docs/product-requirements.md), [architecture](docs/architecture.md), [engineering decisions](docs/decisions.md), and [development](docs/development.md).

`main` is the only permanent branch. Short-lived PR branches must follow the naming standard in `AGENTS.md`; no `codex/` branches. Issue tracking happens through assigned Linear work when authorized.
