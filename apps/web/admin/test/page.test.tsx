import assert from "node:assert/strict";
import test from "node:test";
import { renderToStaticMarkup } from "react-dom/server";
import Page from "../src/app/page";

test("admin renders its distinct app heading", () => {
  const markup = renderToStaticMarkup(<Page />);
  assert.match(markup, /Auray Admin/);
  assert.match(markup, /not implemented yet/);
});
