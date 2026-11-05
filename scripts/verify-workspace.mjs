import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";
import assert from "node:assert/strict";
import test from "node:test";

const apps = [
  ["apps/web/storefront", "@auray/storefront"],
  ["apps/web/admin", "@auray/admin"],
  ["apps/api", "@auray/api"],
];

test("workspace contains the three independently buildable applications", () => {
  for (const [directory, name] of apps) {
    const pkg = JSON.parse(readFileSync(resolve(directory, "package.json"), "utf8"));
    assert.equal(pkg.name, name);
    for (const script of ["dev", "lint", "typecheck", "test", "build"]) {
      assert.equal(typeof pkg.scripts[script], "string");
    }
  }
  assert.ok(existsSync("pnpm-lock.yaml"), "pnpm lockfile must be committed");
});

test("pnpm workspace declares both web apps and the API", () => {
  const yaml = readFileSync("pnpm-workspace.yaml", "utf8");
  assert.match(yaml, /apps\/web\/\*/);
  assert.match(yaml, /apps\/api/);
});
