import { sql } from "drizzle-orm";
import {
  bigint,
  boolean,
  check,
  index,
  integer,
  jsonb,
  pgTable,
  smallint,
  text,
  timestamp,
  uniqueIndex,
  uuid,
  varchar,
} from "drizzle-orm/pg-core";
import type { AnyPgColumn } from "drizzle-orm/pg-core";

const id = () => uuid("id").defaultRandom().primaryKey();
const createdAt = () => timestamp("created_at", { withTimezone: true }).notNull().defaultNow();
const updatedAt = () => timestamp("updated_at", { withTimezone: true }).notNull().defaultNow();
const amount = (name: string) => bigint(name, { mode: "bigint" }).notNull();

export const adminUsers = pgTable(
  "admin_users",
  {
    id: smallint("id").primaryKey().default(1),
    email: varchar("email", { length: 320 }).notNull().unique(),
    passwordHash: text("password_hash").notNull(),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
    disabledAt: timestamp("disabled_at", { withTimezone: true }),
  },
  (table) => [check("admin_users_single_owner_id", sql`${table.id} = 1`)],
);

export const productCategories = pgTable(
  "product_categories",
  {
    id: id(),
    parentId: uuid("parent_id").references((): AnyPgColumn => productCategories.id, { onDelete: "restrict" }),
    slug: varchar("slug", { length: 160 }).notNull().unique(),
    name: varchar("name", { length: 160 }).notNull(),
    description: text("description"),
    sortOrder: integer("sort_order").notNull().default(0),
    isActive: boolean("is_active").notNull().default(true),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [index("product_categories_parent_active_idx").on(table.parentId, table.isActive)],
);

export const products = pgTable(
  "products",
  {
    id: id(),
    categoryId: uuid("category_id").notNull().references(() => productCategories.id, { onDelete: "restrict" }),
    slug: varchar("slug", { length: 180 }).notNull().unique(),
    name: varchar("name", { length: 240 }).notNull(),
    description: text("description"),
    status: varchar("status", { length: 24 }).notNull().default("draft"),
    publishedAt: timestamp("published_at", { withTimezone: true }),
    archivedAt: timestamp("archived_at", { withTimezone: true }),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [
    check("products_status_check", sql`${table.status} in ('draft', 'published', 'archived')`),
    index("products_category_status_idx").on(table.categoryId, table.status),
  ],
);

export const productMedia = pgTable(
  "product_media",
  {
    id: id(),
    productId: uuid("product_id").notNull().references(() => products.id, { onDelete: "restrict" }),
    storageKey: text("storage_key").notNull().unique(),
    publicUrl: text("public_url").notNull(),
    altText: varchar("alt_text", { length: 500 }).notNull(),
    contentType: varchar("content_type", { length: 120 }).notNull(),
    byteSize: bigint("byte_size", { mode: "number" }).notNull(),
    sortOrder: integer("sort_order").notNull().default(0),
    createdAt: createdAt(),
  },
  (table) => [check("product_media_byte_size_positive", sql`${table.byteSize} > 0`), index("product_media_product_idx").on(table.productId, table.sortOrder)],
);

export const productVariants = pgTable(
  "product_variants",
  {
    id: id(),
    productId: uuid("product_id").notNull().references(() => products.id, { onDelete: "restrict" }),
    sku: varchar("sku", { length: 100 }).notNull().unique(),
    size: varchar("size", { length: 80 }).notNull(),
    color: varchar("color", { length: 100 }).notNull(),
    colorCode: varchar("color_code", { length: 16 }),
    priceKobo: amount("price_kobo"),
    isActive: boolean("is_active").notNull().default(true),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [
    uniqueIndex("product_variants_product_size_color_uq").on(table.productId, table.size, table.color),
    check("product_variants_price_nonnegative", sql`${table.priceKobo} >= 0`),
    index("product_variants_product_active_idx").on(table.productId, table.isActive),
  ],
);

export const variantStock = pgTable(
  "variant_stock",
  {
    variantId: uuid("variant_id").primaryKey().references(() => productVariants.id, { onDelete: "restrict" }),
    onHand: integer("on_hand").notNull().default(0),
    reserved: integer("reserved").notNull().default(0),
    updatedAt: updatedAt(),
  },
  (table) => [
    check("variant_stock_on_hand_nonnegative", sql`${table.onHand} >= 0`),
    check("variant_stock_reserved_nonnegative", sql`${table.reserved} >= 0`),
    check("variant_stock_reserved_within_on_hand", sql`${table.reserved} <= ${table.onHand}`),
  ],
);

export const policyDrafts = pgTable(
  "policy_drafts",
  {
    id: smallint("id").primaryKey().default(1),
    content: text("content").notNull(),
    updatedBy: smallint("updated_by").references(() => adminUsers.id, { onDelete: "restrict" }),
    updatedAt: updatedAt(),
  },
  (table) => [check("policy_drafts_singleton_id", sql`${table.id} = 1`)],
);

export const policyVersions = pgTable(
  "policy_versions",
  {
    id: id(),
    versionNumber: integer("version_number").notNull().unique(),
    content: text("content").notNull(),
    contentSha256: varchar("content_sha256", { length: 64 }).notNull(),
    publishedBy: smallint("published_by").references(() => adminUsers.id, { onDelete: "restrict" }),
    publishedAt: timestamp("published_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check("policy_versions_version_positive", sql`${table.versionNumber} > 0`),
    check("policy_versions_sha256_format", sql`${table.contentSha256} ~ '^[0-9a-f]{64}$'`),
  ],
);

export const activePolicy = pgTable(
  "active_policy",
  {
    id: smallint("id").primaryKey().default(1),
    policyVersionId: uuid("policy_version_id").notNull().unique().references(() => policyVersions.id, { onDelete: "restrict" }),
    activatedAt: timestamp("activated_at", { withTimezone: true }).notNull().defaultNow(),
    activatedBy: smallint("activated_by").references(() => adminUsers.id, { onDelete: "restrict" }),
  },
  (table) => [check("active_policy_singleton_id", sql`${table.id} = 1`)],
);

export const checkoutAttempts = pgTable(
  "checkout_attempts",
  {
    id: id(),
    idempotencyKey: varchar("idempotency_key", { length: 160 }).notNull().unique(),
    status: varchar("status", { length: 24 }).notNull().default("started"),
    policyVersionId: uuid("policy_version_id").references(() => policyVersions.id, { onDelete: "restrict" }),
    productTotalKobo: amount("product_total_kobo"),
    createdAt: createdAt(),
    expiresAt: timestamp("expires_at", { withTimezone: true }),
    completedAt: timestamp("completed_at", { withTimezone: true }),
  },
  (table) => [
    check("checkout_attempts_status_check", sql`${table.status} in ('started', 'priced', 'ordered', 'expired', 'failed')`),
    check("checkout_attempts_total_nonnegative", sql`${table.productTotalKobo} >= 0`),
    index("checkout_attempts_status_created_idx").on(table.status, table.createdAt),
  ],
);

export const orders = pgTable(
  "orders",
  {
    id: id(),
    checkoutAttemptId: uuid("checkout_attempt_id").notNull().unique().references(() => checkoutAttempts.id, { onDelete: "restrict" }),
    orderReference: varchar("order_reference", { length: 40 }).notNull().unique(),
    orderStatus: varchar("order_status", { length: 24 }).notNull().default("pending_payment"),
    fulfilmentStatus: varchar("fulfilment_status", { length: 24 }).notNull().default("unfulfilled"),
    customerName: varchar("customer_name", { length: 240 }).notNull(),
    customerEmail: varchar("customer_email", { length: 320 }).notNull(),
    customerPhone: varchar("customer_phone", { length: 40 }).notNull(),
    deliveryAddress: jsonb("delivery_address").$type<Record<string, string>>().notNull(),
    productTotalKobo: amount("product_total_kobo"),
    acceptedPolicyVersionId: uuid("accepted_policy_version_id").notNull().references(() => policyVersions.id, { onDelete: "restrict" }),
    acceptedPolicyContent: text("accepted_policy_content").notNull(),
    policyAcceptedAt: timestamp("policy_accepted_at", { withTimezone: true }).notNull(),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [
    check("orders_status_check", sql`${table.orderStatus} in ('pending_payment', 'paid', 'on_hold', 'cancelled', 'completed')`),
    check("orders_fulfilment_status_check", sql`${table.fulfilmentStatus} in ('unfulfilled', 'processing', 'dispatched', 'delivered', 'returned')`),
    check("orders_product_total_nonnegative", sql`${table.productTotalKobo} >= 0`),
    index("orders_created_idx").on(table.createdAt),
    index("orders_status_created_idx").on(table.orderStatus, table.createdAt),
    index("orders_policy_version_idx").on(table.acceptedPolicyVersionId),
  ],
);

export const orderItems = pgTable(
  "order_items",
  {
    id: id(),
    orderId: uuid("order_id").notNull().references(() => orders.id, { onDelete: "restrict" }),
    productId: uuid("product_id").notNull().references(() => products.id, { onDelete: "restrict" }),
    variantId: uuid("variant_id").notNull().references(() => productVariants.id, { onDelete: "restrict" }),
    productNameSnapshot: varchar("product_name_snapshot", { length: 240 }).notNull(),
    skuSnapshot: varchar("sku_snapshot", { length: 100 }).notNull(),
    sizeSnapshot: varchar("size_snapshot", { length: 80 }).notNull(),
    colorSnapshot: varchar("color_snapshot", { length: 100 }).notNull(),
    unitPriceKobo: amount("unit_price_kobo"),
    quantity: integer("quantity").notNull(),
    lineTotalKobo: amount("line_total_kobo"),
    createdAt: createdAt(),
  },
  (table) => [
    check("order_items_quantity_positive", sql`${table.quantity} > 0`),
    check("order_items_unit_price_nonnegative", sql`${table.unitPriceKobo} >= 0`),
    check("order_items_line_total_nonnegative", sql`${table.lineTotalKobo} >= 0`),
    check("order_items_line_total_matches_quantity", sql`${table.lineTotalKobo} = ${table.unitPriceKobo} * ${table.quantity}`),
    uniqueIndex("order_items_order_variant_uq").on(table.orderId, table.variantId),
    index("order_items_product_idx").on(table.productId),
    index("order_items_variant_idx").on(table.variantId),
  ],
);

export const stockReservations = pgTable(
  "stock_reservations",
  {
    id: id(),
    checkoutAttemptId: uuid("checkout_attempt_id").notNull().references(() => checkoutAttempts.id, { onDelete: "restrict" }),
    orderId: uuid("order_id").references(() => orders.id, { onDelete: "restrict" }),
    variantId: uuid("variant_id").notNull().references(() => productVariants.id, { onDelete: "restrict" }),
    quantity: integer("quantity").notNull(),
    status: varchar("status", { length: 24 }).notNull().default("active"),
    providerExpiryConfirmedAt: timestamp("provider_expiry_confirmed_at", { withTimezone: true }),
    releasedAt: timestamp("released_at", { withTimezone: true }),
    consumedAt: timestamp("consumed_at", { withTimezone: true }),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [
    check("stock_reservations_quantity_positive", sql`${table.quantity} > 0`),
    check("stock_reservations_status_check", sql`${table.status} in ('active', 'released', 'consumed', 'on_hold')`),
    uniqueIndex("stock_reservations_checkout_variant_uq").on(table.checkoutAttemptId, table.variantId),
    index("stock_reservations_variant_status_idx").on(table.variantId, table.status),
    index("stock_reservations_active_created_idx").on(table.createdAt).where(sql`${table.status} = 'active'`),
  ],
);

export const deliveryQuotes = pgTable(
  "delivery_quotes",
  {
    id: id(),
    orderId: uuid("order_id").notNull().references(() => orders.id, { onDelete: "restrict" }),
    quotedAmountKobo: amount("quoted_amount_kobo"),
    currency: varchar("currency", { length: 3 }).notNull().default("NGN"),
    status: varchar("status", { length: 20 }).notNull().default("quoted"),
    notes: text("notes"),
    quotedBy: smallint("quoted_by").references(() => adminUsers.id, { onDelete: "restrict" }),
    quotedAt: timestamp("quoted_at", { withTimezone: true }).notNull().defaultNow(),
    acceptedAt: timestamp("accepted_at", { withTimezone: true }),
    supersededAt: timestamp("superseded_at", { withTimezone: true }),
  },
  (table) => [
    check("delivery_quotes_amount_positive", sql`${table.quotedAmountKobo} > 0`),
    check("delivery_quotes_currency_ngn", sql`${table.currency} = 'NGN'`),
    check("delivery_quotes_status_check", sql`${table.status} in ('quoted', 'accepted', 'declined', 'superseded')`),
    index("delivery_quotes_order_created_idx").on(table.orderId, table.quotedAt),
  ],
);

export const deliveryPaymentEvents = pgTable(
  "delivery_payment_events",
  {
    id: id(),
    orderId: uuid("order_id").notNull().references(() => orders.id, { onDelete: "restrict" }),
    quoteId: uuid("quote_id").references(() => deliveryQuotes.id, { onDelete: "restrict" }),
    status: varchar("status", { length: 20 }).notNull(),
    notes: text("notes"),
    recordedBy: smallint("recorded_by").references(() => adminUsers.id, { onDelete: "restrict" }),
    recordedAt: timestamp("recorded_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check("delivery_payment_events_status_check", sql`${table.status} in ('unpaid', 'paid', 'waived', 'refunded')`),
    index("delivery_payment_events_order_recorded_idx").on(table.orderId, table.recordedAt),
  ],
);

export const guestOrderTokens = pgTable(
  "guest_order_tokens",
  {
    id: id(),
    orderId: uuid("order_id").notNull().references(() => orders.id, { onDelete: "restrict" }),
    tokenHash: varchar("token_hash", { length: 64 }).notNull().unique(),
    issuedAt: timestamp("issued_at", { withTimezone: true }).notNull().defaultNow(),
    expiresAt: timestamp("expires_at", { withTimezone: true }).notNull(),
    revokedAt: timestamp("revoked_at", { withTimezone: true }),
    replacesTokenId: uuid("replaces_token_id").references((): AnyPgColumn => guestOrderTokens.id, { onDelete: "restrict" }),
  },
  (table) => [
    check("guest_order_tokens_hash_format", sql`${table.tokenHash} ~ '^[0-9a-f]{64}$'`),
    check("guest_order_tokens_ninety_days", sql`${table.expiresAt} = ${table.issuedAt} + interval '90 days'`),
    uniqueIndex("guest_order_tokens_one_active_per_order_uq").on(table.orderId).where(sql`${table.revokedAt} is null`),
    index("guest_order_tokens_expiry_idx").on(table.expiresAt).where(sql`${table.revokedAt} is null`),
  ],
);

export const paymentAttempts = pgTable(
  "payment_attempts",
  {
    id: id(),
    orderId: uuid("order_id").notNull().references(() => orders.id, { onDelete: "restrict" }),
    idempotencyKey: varchar("idempotency_key", { length: 160 }).notNull().unique(),
    provider: varchar("provider", { length: 80 }).notNull(),
    status: varchar("status", { length: 24 }).notNull().default("created"),
    amountKobo: amount("amount_kobo"),
    orderCurrency: varchar("order_currency", { length: 3 }).notNull().default("NGN"),
    providerAmount: varchar("provider_amount", { length: 100 }),
    providerCurrency: varchar("provider_currency", { length: 3 }),
    providerAmountUnit: varchar("provider_amount_unit", { length: 80 }),
    conversionBasis: jsonb("conversion_basis").$type<Record<string, unknown>>(),
    providerReference: varchar("provider_reference", { length: 180 }),
    initiatedAt: timestamp("initiated_at", { withTimezone: true }),
    confirmedAt: timestamp("confirmed_at", { withTimezone: true }),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [
    check("payment_attempts_status_check", sql`${table.status} in ('created', 'pending', 'succeeded', 'failed', 'cancelled', 'disputed', 'underpaid', 'on_hold')`),
    check("payment_attempts_amount_nonnegative", sql`${table.amountKobo} >= 0`),
    check("payment_attempts_order_currency_ngn", sql`${table.orderCurrency} = 'NGN'`),
    check("payment_attempts_provider_currency_format", sql`${table.providerCurrency} is null or ${table.providerCurrency} ~ '^[A-Z]{3}$'`),
    check("payment_attempts_provider_amount_format", sql`${table.providerAmount} is null or ${table.providerAmount} ~ '^[0-9]+(\\.[0-9]+)?$'`),
    check("payment_attempts_provider_tuple_complete", sql`${table.status} = 'created' or (${table.providerAmount} is not null and ${table.providerCurrency} is not null and ${table.providerAmountUnit} is not null and (${table.providerCurrency} = 'NGN' or ${table.conversionBasis} is not null))`),
    uniqueIndex("payment_attempts_provider_reference_uq").on(table.provider, table.providerReference).where(sql`${table.providerReference} is not null`),
    index("payment_attempts_order_created_idx").on(table.orderId, table.createdAt),
    index("payment_attempts_reconcile_idx").on(table.status, table.createdAt).where(sql`${table.status} in ('pending', 'underpaid', 'on_hold')`),
  ],
);

export const providerWebhookEvents = pgTable(
  "provider_webhook_events",
  {
    id: id(),
    paymentAttemptId: uuid("payment_attempt_id").references(() => paymentAttempts.id, { onDelete: "restrict" }),
    provider: varchar("provider", { length: 80 }).notNull(),
    providerEventId: varchar("provider_event_id", { length: 200 }).notNull(),
    eventType: varchar("event_type", { length: 160 }).notNull(),
    payloadSha256: varchar("payload_sha256", { length: 64 }).notNull(),
    signatureVerifiedAt: timestamp("signature_verified_at", { withTimezone: true }),
    receivedAt: timestamp("received_at", { withTimezone: true }).notNull().defaultNow(),
    processedAt: timestamp("processed_at", { withTimezone: true }),
    processingStatus: varchar("processing_status", { length: 24 }).notNull().default("received"),
    failureCode: varchar("failure_code", { length: 80 }),
  },
  (table) => [
    uniqueIndex("provider_webhook_events_provider_id_uq").on(table.provider, table.providerEventId),
    check("provider_webhook_events_hash_format", sql`${table.payloadSha256} ~ '^[0-9a-f]{64}$'`),
    check("provider_webhook_events_status_check", sql`${table.processingStatus} in ('received', 'processing', 'processed', 'failed', 'ignored')`),
    check("provider_webhook_events_processed_signature_check", sql`${table.processingStatus} <> 'processed' or ${table.signatureVerifiedAt} is not null`),
    index("provider_webhook_events_attempt_idx").on(table.paymentAttemptId),
  ],
);

export const paymentEvents = pgTable(
  "payment_events",
  {
    id: id(),
    paymentAttemptId: uuid("payment_attempt_id").notNull().references(() => paymentAttempts.id, { onDelete: "restrict" }),
    webhookEventId: uuid("webhook_event_id").references(() => providerWebhookEvents.id, { onDelete: "restrict" }),
    eventType: varchar("event_type", { length: 100 }).notNull(),
    previousStatus: varchar("previous_status", { length: 24 }),
    nextStatus: varchar("next_status", { length: 24 }).notNull(),
    details: jsonb("details").$type<Record<string, unknown>>().notNull().default({}),
    recordedAt: timestamp("recorded_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check("payment_events_next_status_check", sql`${table.nextStatus} in ('created', 'pending', 'succeeded', 'failed', 'cancelled', 'disputed', 'underpaid', 'on_hold')`),
    check("payment_events_previous_status_check", sql`${table.previousStatus} is null or ${table.previousStatus} in ('created', 'pending', 'succeeded', 'failed', 'cancelled', 'disputed', 'underpaid', 'on_hold')`),
    index("payment_events_attempt_recorded_idx").on(table.paymentAttemptId, table.recordedAt),
    uniqueIndex("payment_events_webhook_uq").on(table.webhookEventId).where(sql`${table.webhookEventId} is not null`),
  ],
);

export const refundRequests = pgTable(
  "refund_requests",
  {
    id: id(),
    paymentAttemptId: uuid("payment_attempt_id").notNull().references(() => paymentAttempts.id, { onDelete: "restrict" }),
    idempotencyKey: varchar("idempotency_key", { length: 160 }).notNull().unique(),
    amountKobo: amount("amount_kobo"),
    currency: varchar("currency", { length: 3 }).notNull().default("NGN"),
    status: varchar("status", { length: 24 }).notNull().default("requested"),
    requestedBy: smallint("requested_by").notNull().references(() => adminUsers.id, { onDelete: "restrict" }),
    reason: text("reason"),
    requestedAt: timestamp("requested_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: updatedAt(),
  },
  (table) => [
    check("refund_requests_amount_positive", sql`${table.amountKobo} > 0`),
    check("refund_requests_currency_ngn", sql`${table.currency} = 'NGN'`),
    check("refund_requests_status_check", sql`${table.status} in ('requested', 'pending', 'succeeded', 'failed', 'cancelled')`),
    index("refund_requests_payment_status_idx").on(table.paymentAttemptId, table.status),
  ],
);

export const refundAttempts = pgTable(
  "refund_attempts",
  {
    id: id(),
    refundRequestId: uuid("refund_request_id").notNull().references(() => refundRequests.id, { onDelete: "restrict" }),
    provider: varchar("provider", { length: 80 }).notNull(),
    providerReference: varchar("provider_reference", { length: 180 }),
    status: varchar("status", { length: 24 }).notNull().default("pending"),
    providerAmount: varchar("provider_amount", { length: 100 }),
    providerCurrency: varchar("provider_currency", { length: 3 }),
    initiatedAt: timestamp("initiated_at", { withTimezone: true }).notNull().defaultNow(),
    confirmedAt: timestamp("confirmed_at", { withTimezone: true }),
  },
  (table) => [
    check("refund_attempts_status_check", sql`${table.status} in ('pending', 'succeeded', 'failed')`),
    check("refund_attempts_provider_currency_format", sql`${table.providerCurrency} is null or ${table.providerCurrency} ~ '^[A-Z]{3}$'`),
    check("refund_attempts_provider_amount_format", sql`${table.providerAmount} is null or ${table.providerAmount} ~ '^[0-9]+(\\.[0-9]+)?$'`),
    uniqueIndex("refund_attempts_provider_reference_uq").on(table.provider, table.providerReference).where(sql`${table.providerReference} is not null`),
    index("refund_attempts_refund_idx").on(table.refundRequestId, table.initiatedAt),
  ],
);

export const refundEvents = pgTable(
  "refund_events",
  {
    id: id(),
    refundRequestId: uuid("refund_request_id").notNull().references(() => refundRequests.id, { onDelete: "restrict" }),
    refundAttemptId: uuid("refund_attempt_id").references(() => refundAttempts.id, { onDelete: "restrict" }),
    eventType: varchar("event_type", { length: 100 }).notNull(),
    status: varchar("status", { length: 24 }).notNull(),
    details: jsonb("details").$type<Record<string, unknown>>().notNull().default({}),
    recordedAt: timestamp("recorded_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check("refund_events_status_check", sql`${table.status} in ('requested', 'pending', 'succeeded', 'failed', 'cancelled')`),
    index("refund_events_request_recorded_idx").on(table.refundRequestId, table.recordedAt),
  ],
);

export const adminSessions = pgTable(
  "admin_sessions",
  {
    id: id(),
    adminUserId: smallint("admin_user_id").notNull().references(() => adminUsers.id, { onDelete: "restrict" }),
    tokenHash: varchar("token_hash", { length: 64 }).notNull().unique(),
    createdAt: createdAt(),
    lastActivityAt: timestamp("last_activity_at", { withTimezone: true }).notNull().defaultNow(),
    expiresAt: timestamp("expires_at", { withTimezone: true }).notNull(),
    revokedAt: timestamp("revoked_at", { withTimezone: true }),
  },
  (table) => [
    check("admin_sessions_hash_format", sql`${table.tokenHash} ~ '^[0-9a-f]{64}$'`),
    check("admin_sessions_expiry_after_creation", sql`${table.expiresAt} > ${table.createdAt}`),
    index("admin_sessions_user_expiry_idx").on(table.adminUserId, table.expiresAt),
    index("admin_sessions_active_expiry_idx").on(table.expiresAt).where(sql`${table.revokedAt} is null`),
  ],
);

export const emailOutbox = pgTable(
  "email_outbox",
  {
    id: id(),
    idempotencyKey: varchar("idempotency_key", { length: 180 }).notNull().unique(),
    eventType: varchar("event_type", { length: 120 }).notNull(),
    recipient: varchar("recipient", { length: 320 }).notNull(),
    payload: jsonb("payload").$type<Record<string, unknown>>().notNull(),
    status: varchar("status", { length: 20 }).notNull().default("pending"),
    attemptCount: integer("attempt_count").notNull().default(0),
    availableAt: timestamp("available_at", { withTimezone: true }).notNull().defaultNow(),
    claimedUntil: timestamp("claimed_until", { withTimezone: true }),
    deliveredAt: timestamp("delivered_at", { withTimezone: true }),
    lastErrorCode: varchar("last_error_code", { length: 80 }),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (table) => [
    check("email_outbox_status_check", sql`${table.status} in ('pending', 'processing', 'sent', 'failed', 'cancelled')`),
    check("email_outbox_attempt_count_nonnegative", sql`${table.attemptCount} >= 0`),
    index("email_outbox_pending_idx").on(table.availableAt, table.createdAt).where(sql`${table.status} in ('pending', 'processing')`),
  ],
);

export const emailDeliveryEvents = pgTable(
  "email_delivery_events",
  {
    id: id(),
    outboxId: uuid("outbox_id").notNull().references(() => emailOutbox.id, { onDelete: "restrict" }),
    provider: varchar("provider", { length: 80 }).notNull(),
    providerEventId: varchar("provider_event_id", { length: 200 }).notNull(),
    eventType: varchar("event_type", { length: 100 }).notNull(),
    occurredAt: timestamp("occurred_at", { withTimezone: true }).notNull(),
    receivedAt: timestamp("received_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex("email_delivery_events_provider_event_uq").on(table.provider, table.providerEventId),
    index("email_delivery_events_outbox_idx").on(table.outboxId, table.receivedAt),
  ],
);

export const auditEvents = pgTable(
  "audit_events",
  {
    id: id(),
    actorAdminId: smallint("actor_admin_id").references(() => adminUsers.id, { onDelete: "restrict" }),
    action: varchar("action", { length: 120 }).notNull(),
    entityType: varchar("entity_type", { length: 100 }).notNull(),
    entityId: varchar("entity_id", { length: 180 }),
    details: jsonb("details").$type<Record<string, unknown>>().notNull().default({}),
    occurredAt: timestamp("occurred_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [index("audit_events_entity_idx").on(table.entityType, table.entityId, table.occurredAt), index("audit_events_actor_idx").on(table.actorAdminId, table.occurredAt)],
);

export const storeSettings = pgTable(
  "store_settings",
  {
    id: smallint("id").primaryKey().default(1),
    businessName: varchar("business_name", { length: 200 }).notNull(),
    supportEmail: varchar("support_email", { length: 320 }),
    supportPhone: varchar("support_phone", { length: 40 }),
    supportAddress: text("support_address"),
    supportHours: text("support_hours"),
    updatedBy: smallint("updated_by").references(() => adminUsers.id, { onDelete: "restrict" }),
    updatedAt: updatedAt(),
  },
  (table) => [check("store_settings_singleton_id", sql`${table.id} = 1`)],
);

export const schema = {
  activePolicy,
  adminSessions,
  adminUsers,
  auditEvents,
  checkoutAttempts,
  deliveryPaymentEvents,
  deliveryQuotes,
  emailDeliveryEvents,
  emailOutbox,
  guestOrderTokens,
  orderItems,
  orders,
  paymentAttempts,
  paymentEvents,
  policyDrafts,
  policyVersions,
  productCategories,
  productMedia,
  productVariants,
  products,
  providerWebhookEvents,
  refundAttempts,
  refundEvents,
  refundRequests,
  stockReservations,
  storeSettings,
  variantStock,
};
