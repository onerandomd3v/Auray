import assert from "node:assert/strict";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { config as loadEnv } from "dotenv";
import { migrate } from "drizzle-orm/node-postgres/migrator";
import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import { test } from "node:test";

loadEnv({ path: resolve(process.cwd(), "../../.env.local") });

test("commerce migrations apply repeatedly and enforce database invariants", async (context) => {
  const connectionString = process.env.AURAY_TEST_DATABASE_URL;
  assert.ok(connectionString, "AURAY_TEST_DATABASE_URL is required for database integration tests");
  const target = new URL(connectionString);
  assert.ok(["localhost", "127.0.0.1", "::1"].includes(target.hostname), "test database must be local");
  assert.equal(target.pathname, "/auray_test", "tests may only use the dedicated auray_test database");

  const pool = new Pool({ connectionString });
  context.after(async () => pool.end());
  const db = drizzle(pool);
  const migrationsFolder = fileURLToPath(new URL("../drizzle", import.meta.url));

  await migrate(db, { migrationsFolder });
  await migrate(db, { migrationsFolder });
  await pool.query(`TRUNCATE TABLE
    active_policy, admin_sessions, admin_users, audit_events, checkout_attempts,
    delivery_payment_events, delivery_quotes, email_delivery_events, email_outbox,
    guest_order_tokens, order_items, orders, payment_attempts, payment_events,
    policy_drafts, policy_versions, product_categories, product_media, product_variants,
    products, provider_webhook_events, refund_attempts, refund_events, refund_requests,
    stock_reservations, store_settings, variant_stock CASCADE`);

  const { rows: tables } = await pool.query<{ count: string }>(
    "select count(*)::text as count from information_schema.tables where table_schema = 'public' and table_type = 'BASE TABLE'",
  );
  assert.equal(Number(tables[0]?.count), 27, "expected all commerce tables in public schema");

  const { rows: adminRows } = await pool.query<{ id: number }>(
    "insert into admin_users (email, password_hash) values ($1, $2) returning id",
    ["schema-test@example.invalid", "test-hash"],
  );
  const adminId = adminRows[0]!.id;
  const { rows: policyRows } = await pool.query<{ id: string }>(
    "insert into policy_versions (version_number, content, content_sha256, published_by) values (1, 'test policy', $1, $2) returning id",
    ["a".repeat(64), adminId],
  );
  const policyId = policyRows[0]!.id;
  const { rows: categoryRows } = await pool.query<{ id: string }>(
    "insert into product_categories (slug, name) values ('test-category', 'Test category') returning id",
  );
  const { rows: productRows } = await pool.query<{ id: string }>(
    "insert into products (category_id, slug, name) values ($1, 'test-product', 'Test product') returning id",
    [categoryRows[0]!.id],
  );
  const { rows: variantRows } = await pool.query<{ id: string }>(
    "insert into product_variants (product_id, sku, size, color, price_kobo) values ($1, 'TEST-1', 'M', 'Black', 2500) returning id",
    [productRows[0]!.id],
  );

  await assert.rejects(
    pool.query("insert into variant_stock (variant_id, on_hand, reserved) values ($1, -1, 0)", [variantRows[0]!.id]),
    { code: "23514" },
    "negative stock must be rejected",
  );
  await pool.query("insert into variant_stock (variant_id, on_hand, reserved) values ($1, 5, 1)", [variantRows[0]!.id]);
  const { rows: checkoutRows } = await pool.query<{ id: string }>(
    "insert into checkout_attempts (idempotency_key, status, policy_version_id, product_total_kobo) values ('schema-test-checkout', 'priced', $1, 2500) returning id",
    [policyId],
  );
  const { rows: orderRows } = await pool.query<{ id: string }>(
    "insert into orders (checkout_attempt_id, order_reference, customer_name, customer_email, customer_phone, delivery_address, product_total_kobo, accepted_policy_version_id, accepted_policy_content, policy_accepted_at) values ($1, 'TEST-ORDER-1', 'Test buyer', 'buyer@example.invalid', '+2340000000000', '{}'::jsonb, 2500, $2, 'test policy', now()) returning id",
    [checkoutRows[0]!.id, policyId],
  );
  const { rows: itemRows } = await pool.query<{ id: string }>(
    "insert into order_items (order_id, product_id, variant_id, product_name_snapshot, sku_snapshot, size_snapshot, color_snapshot, unit_price_kobo, quantity, line_total_kobo) values ($1, $2, $3, 'Test product', 'TEST-1', 'M', 'Black', 2500, 1, 2500) returning id",
    [orderRows[0]!.id, productRows[0]!.id, variantRows[0]!.id],
  );
  await assert.rejects(
    pool.query("update order_items set product_name_snapshot = 'changed' where id = $1", [itemRows[0]!.id]),
    { code: "55000" },
    "order item snapshots must be immutable",
  );
  await assert.rejects(
    pool.query("update policy_versions set content = 'changed' where id = $1", [policyId]),
    { code: "55000" },
    "published policies must be immutable",
  );
  await assert.rejects(
    pool.query("insert into provider_webhook_events (provider, provider_event_id, event_type, payload_sha256, processing_status) values ('bachs', 'unverified-test-event', 'payment.succeeded', $1, 'processed')", ["c".repeat(64)]),
    { code: "23514" },
    "a webhook cannot be marked processed before signature verification",
  );
  const { rows: secondVariantRows } = await pool.query<{ id: string }>(
    "insert into product_variants (product_id, sku, size, color, price_kobo) values ($1, 'TEST-2', 'M', 'Blue', 2500) returning id",
    [productRows[0]!.id],
  );
  await assert.rejects(
    pool.query("insert into order_items (order_id, product_id, variant_id, product_name_snapshot, sku_snapshot, size_snapshot, color_snapshot, unit_price_kobo, quantity, line_total_kobo) values ($1, $2, $3, 'Test product', 'TEST-2', 'M', 'Blue', 2500, 2, 2500)", [orderRows[0]!.id, productRows[0]!.id, secondVariantRows[0]!.id]),
    { code: "23514" },
    "line totals must equal unit price times quantity",
  );
  await assert.rejects(
    pool.query("insert into payment_attempts (order_id, idempotency_key, provider, status, amount_kobo, order_currency) values ($1, 'invalid-provider-tuple', 'bachs', 'pending', 2500, 'NGN')", [orderRows[0]!.id]),
    { code: "23514" },
    "provider settlement metadata must be complete",
  );
  await assert.rejects(
    pool.query("insert into guest_order_tokens (order_id, token_hash, issued_at, expires_at) values ($1, $2, now(), now() + interval '89 days')", [orderRows[0]!.id, "b".repeat(64)]),
    { code: "23514" },
    "guest tokens must expire after exactly 90 days",
  );
});
