# Auray

Fashion-commerce platform developed by CodedDevs Technology LTD for Auray.

## Status
Engineering foundation only. Product features are **not yet implemented**. Approved PRD/TDD remain the source of truth; this repository records the implementation standards and deployment boundaries.

## Applications
- `apps/web/storefront` — standalone Next.js customer storefront.
- `apps/web/admin` — standalone Next.js owner dashboard.
- `apps/api` — NestJS REST API and all business logic.
- `packages/` — only genuinely shared, non-secret contracts/configuration.

See [architecture](docs/architecture.md), [development](docs/development.md), [engineering decisions](docs/decisions.md), and [repository rules](AGENTS.md).

## Branch strategy
`main` is the **only permanent branch**. Work in short-lived feature branches and open PRs targeting `main`. Squash merge after checks and review. No `dev` or `develop` branch. No Linear issues are created as part of this bootstrap.

## Bootstrap note
Framework applications, package versions, lockfile, real app build/test workflows, and production deployment are not yet initialized. The bootstrap CI checks validate documentation and structure only; do not interpret them as proof that apps build or run.
