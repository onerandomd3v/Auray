# Implementation handoff and decision authority

## What is approved
The fashion commerce requirements in [product requirements](product-requirements.md), technical architecture in [architecture](architecture.md), and decisions in [decisions](decisions.md) are approved. The earlier TDD was approved as the implementation baseline on 5 November 2026. Agents must not independently substitute a different payment provider, database, framework, checkout model, delivery fee policy, or account model.

## What has actually been implemented
- GitHub repo, protected `main` (repository settings are managed through GitHub; verify actual enforcement in the UI), engineering/agent instructions, root pnpm workspace and lockfile.
- Independently runnable Next.js storefront/admin scaffolds using Tailwind CSS v4; NestJS API scaffold with health endpoint.
- Four GitHub Actions CI checks for workspace, storefront, admin and API. Current test coverage validates the scaffold; it does **not** prove payment, inventory, security or production functionality.
- No real commerce modules, database schema/migrations, auth implementation, Bachs/SendByte/R2 integration or production deployment yet. These are **approved work to implement**, not tentative features.

## When to ask for a decision
Do not ask the owner to reapprove settled architecture. Investigate docs/code/provider references first. Ask only when:
1. Requirements conflict, or a material new product/security choice is not established.
2. A Bachs/SendByte sandbox test reveals that the approved experience cannot work as described.
3. A change to commercial scope, customer-facing policy, or production infrastructure requires explicit authorization.
4. Credentials, merchant settings, domain/VPS ownership, final brand assets or other external inputs are truly unavailable. Never guess credentials, prices or provider capabilities.

## Implementable technical specifics
Use the approved TDD's indicative schema and API contract as an engineering starting point. For entity/field names, indexes, endpoint details and testing fixtures, make locally reasonable choices consistent with the approved invariants and document them in the implementation PR; these are not an excuse to redo product planning. Stateful security decisions such as guest-token expiration/reissue and MFA enrollment need a secure, reviewable policy before shipping.

## Linear execution boundary
Engineering setup and standards are complete enough to begin **planning and assigning Linear issues**. Feature implementation should be tracked as scoped issues with acceptance tests and dependencies; every change receives a short-lived branch and focused PR to `main`. Do not create Linear issues autonomously without the user's authorization.

## Source-of-truth handling
- Public repository: approved **non-commercial** technical/product guidance in Markdown.
- Signed PRD, Scope of Work, contract and client communications: controlled private project records, not public Git content.
- Approved TDD: project-approved technical baseline. It is summarized in repository Markdown so an agent can start coding, but a full internal document should be made accessible through a permissioned project source if detailed traceability is required.
- Conflicts between public Markdown and privately approved documents should be flagged and corrected, not silently resolved by inventing terms.
