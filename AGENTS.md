# Auray repository instructions

Read `README.md`, `docs/product-requirements.md`, `docs/architecture.md`, `docs/decisions.md`, `docs/development.md` and relevant nested `AGENTS.md` before changes. The signed PRD and approved TDD govern product and architecture; repository Markdown translates their approved, non-commercial technical requirements into coding-agent instructions. Do not infer new requirements from unavailable documents or claim implementation equals approval.

## Repository and Git
- Canonical repository: `onerandomd3v/Auray`; target `main` only. No long-lived development branch.
- Use a short-lived task branch with prefix `feat/`, `fix/`, `chore/`, `docs/`, `test/`, `refactor/`, `ci/`, or `security/`. **Never use `codex/`, `agent/`, `ai/`, `dev/`, `develop/`, or tool/person-name prefixes**; override automatic branch naming. Reference actual assigned Linear issue IDs only. One focused PR to `main` per change; update from `main`, resolve reviews, and squash merge. No direct pushes or automatic merges.
- Do not create Linear issues without authorization. Once the backlog is approved, use assigned issue IDs in branches and PRs; never invent IDs. Document actual verification, risk and impact in each PR.
- Use separate Git worktrees for parallel implementation work; avoid multiple agents editing the same worktree.
- Preserve app boundaries: `apps/web/storefront`, `apps/web/admin`, `apps/api`; avoid unnecessary shared packages.
- Never change approved product or architecture decisions, introduce services, or reinterpret client policy without approval. `docs/decisions.md` explicitly distinguishes approved choices from provider sandbox verification.
- No secrets, private client documents, customer data, or credentials in Git; no production access or migrations without explicit authorization.

## Required technical choices
- Node.js 24, TypeScript, pnpm workspaces, standalone Next.js storefront and admin using Tailwind CSS v4, NestJS modular-monolith REST API, PostgreSQL + Drizzle ORM.
- Cloudflare proxied DNS/WAF, R2 media, client-provided VPS, Docker Compose, Caddy; provider adapters for Bachs, SendByte, object storage.
- Do not add Redis, queues, microservices, customer accounts, or shipping-provider integration by default.

## Safety and business invariants
- NestJS owns pricing, product/variant stock, guest orders, policy acceptance, authentication, payments and fulfilment. Browser data is untrusted.
- Product payment via Bachs; delivery quoted and paid outside the website. Do not confuse checkout completion with settled funds.
- Variant-level inventory reservations must be transactional and concurrency-safe. Provider expiry/late payment reconciliation is required before release.
- Verify signed Bachs webhook payloads and enforce idempotency, amount/currency matching and audit history.
- Email is required during guest checkout; no mandatory OTP. SendByte emails use an outbox and retries; email failures never reverse checkout/payment.
- Admin uses host-only HttpOnly Secure cookies and server-side authorization. Guest order access requires unguessable private read-only tokens.
- Protect sensitive endpoints from CSRF, abuse and data leaks; do not log secrets, tokens or personal data.

## Development and verification
- Look at existing code before editing, use reviewed Drizzle SQL migrations, test financial/inventory/security changes with real PostgreSQL where relevant.
- Never claim CI or tests pass unless actually run. Treat placeholder/scaffold checks as such.
- Follow approved brand/design artifacts when available; don't invent a design system.
- Read the closest nested `AGENTS.md` for app-specific instructions.

## References
- `docs/product-requirements.md`: approved product behaviours and acceptance invariants
- `docs/architecture.md`: boundaries and deployable components
- `docs/decisions.md`: approved decisions, explicitly open validations
- `docs/development.md`: local setup, verification and Git workflow
- `docs/security.md`: authentication, checkout, webhook and data protection
- `docs/operations.md`: Cloudflare, VPS, backups, migrations and recovery
- `docs/agent-workflow.md`: optional specialist subagents, their authority and review
- `.codex/agents/` and [`docs/agent-workflow.md`](docs/agent-workflow.md): Luna implementation and Sol technical-advisory workflow

- `docs/testing.md`: testing and integration evidence requirements
