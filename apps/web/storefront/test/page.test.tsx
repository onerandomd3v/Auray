import assert from "node:assert/strict";
import test from "node:test";
import { renderToStaticMarkup } from "react-dom/server";
import Page from "../src/app/page";

test("storefront renders its distinct app heading", () => {
  const markup = renderToStaticMarkup(<Page />);
  assert.match(markup, /Auray Storefront/);
  assert.match(markup, /not implemented yet/);
});
