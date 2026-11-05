# Coding agent and subagent workflow

Codex reads `AGENTS.md` recursively in the directory hierarchy. Do not use a file named `subagents.md` as if Codex automatically executes it; project-specific custom subagent definitions live under `.codex/agents/*.toml`.

## Default execution
One responsible implementation agent per focused branch/worktree. Read approved requirements and active code before changes. Write a concise plan, implement, validate, inspect the diff, create PR against `main`. Do not merge or touch production without explicit authorization.

## Optional specialists
- `architecture-reviewer`: read-focused review of boundaries and decisions.
- `security-reviewer`: adversarial review of sessions, payment, webhooks and guest privacy.
- `test-reviewer`: independent test gaps, integration/CI evidence and regressions.

Only delegate when parallel read-heavy work adds value. Specialists must report findings and evidence, not silently alter code; their instructions **do not enforce a read-only sandbox**. Ensure no two agents edit the same worktree. Parent agent owns final validation and reporting.

See OpenAI's Codex AGENTS.md and subagent documentation for instruction discovery and TOML format.
