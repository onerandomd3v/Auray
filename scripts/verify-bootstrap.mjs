import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
const scope = process.argv[2] ?? "workspace";
const required = {
  workspace: ["README.md","AGENTS.md","docs/architecture.md","docs/decisions.md","docs/development.md","docs/security.md","docs/operations.md","docs/agent-workflow.md"],
  storefront: ["apps/web/storefront/AGENTS.md","apps/web/storefront/README.md"],
  admin: ["apps/web/admin/AGENTS.md","apps/web/admin/README.md"],
  api: ["apps/api/AGENTS.md","apps/api/README.md"]
};
if (!Object.hasOwn(required, scope)) { console.error("Unknown scope",scope); process.exit(2); }
for (const file of required[scope]) {
  if (!existsSync(resolve(file))) { console.error("Missing:",file); process.exitCode=1; }
  else if (!readFileSync(resolve(file),"utf8").trim()) { console.error("Empty:",file); process.exitCode=1; }
}
console.log("BOOTSTRAP ONLY:",scope,"documentation/structure checked. No application tests, build, or lint were run.");
