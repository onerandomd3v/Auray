import assert from "node:assert/strict";
import test from "node:test";
import { getHealth } from "../src/health.js";

test("health reports API scaffold status", () => {
  assert.deepEqual(getHealth(), { status: "ok", service: "api" });
});
