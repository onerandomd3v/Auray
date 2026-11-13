CREATE TABLE "active_policy" (
	"id" smallint PRIMARY KEY DEFAULT 1 NOT NULL,
	"policy_version_id" uuid NOT NULL,
	"activated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"activated_by" smallint,
	CONSTRAINT "active_policy_policy_version_id_unique" UNIQUE("policy_version_id"),
	CONSTRAINT "active_policy_singleton_id" CHECK ("active_policy"."id" = 1)
);
--> statement-breakpoint
CREATE TABLE "admin_sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"admin_user_id" smallint NOT NULL,
	"token_hash" varchar(64) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"last_activity_at" timestamp with time zone DEFAULT now() NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"revoked_at" timestamp with time zone,
	CONSTRAINT "admin_sessions_token_hash_unique" UNIQUE("token_hash"),
	CONSTRAINT "admin_sessions_hash_format" CHECK ("admin_sessions"."token_hash" ~ '^[0-9a-f]{64}$'),
	CONSTRAINT "admin_sessions_expiry_after_creation" CHECK ("admin_sessions"."expires_at" > "admin_sessions"."created_at")
);
--> statement-breakpoint
CREATE TABLE "admin_users" (
	"id" smallint PRIMARY KEY DEFAULT 1 NOT NULL,
	"email" varchar(320) NOT NULL,
	"password_hash" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"disabled_at" timestamp with time zone,
	CONSTRAINT "admin_users_email_unique" UNIQUE("email"),
	CONSTRAINT "admin_users_single_owner_id" CHECK ("admin_users"."id" = 1)
);
--> statement-breakpoint
CREATE TABLE "audit_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"actor_admin_id" smallint,
	"action" varchar(120) NOT NULL,
	"entity_type" varchar(100) NOT NULL,
	"entity_id" varchar(180),
	"details" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"occurred_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "checkout_attempts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"idempotency_key" varchar(160) NOT NULL,
	"status" varchar(24) DEFAULT 'started' NOT NULL,
	"policy_version_id" uuid,
	"product_total_kobo" bigint NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"expires_at" timestamp with time zone,
	"completed_at" timestamp with time zone,
	CONSTRAINT "checkout_attempts_idempotency_key_unique" UNIQUE("idempotency_key"),
	CONSTRAINT "checkout_attempts_status_check" CHECK ("checkout_attempts"."status" in ('started', 'priced', 'ordered', 'expired', 'failed')),
	CONSTRAINT "checkout_attempts_total_nonnegative" CHECK ("checkout_attempts"."product_total_kobo" >= 0)
);
--> statement-breakpoint
CREATE TABLE "delivery_payment_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"order_id" uuid NOT NULL,
	"quote_id" uuid,
	"status" varchar(20) NOT NULL,
	"notes" text,
	"recorded_by" smallint,
	"recorded_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "delivery_payment_events_status_check" CHECK ("delivery_payment_events"."status" in ('unpaid', 'paid', 'waived', 'refunded'))
);
--> statement-breakpoint
CREATE TABLE "delivery_quotes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"order_id" uuid NOT NULL,
	"quoted_amount_kobo" bigint NOT NULL,
	"currency" varchar(3) DEFAULT 'NGN' NOT NULL,
	"status" varchar(20) DEFAULT 'quoted' NOT NULL,
	"notes" text,
	"quoted_by" smallint,
	"quoted_at" timestamp with time zone DEFAULT now() NOT NULL,
	"accepted_at" timestamp with time zone,
	"superseded_at" timestamp with time zone,
	CONSTRAINT "delivery_quotes_amount_positive" CHECK ("delivery_quotes"."quoted_amount_kobo" > 0),
	CONSTRAINT "delivery_quotes_currency_ngn" CHECK ("delivery_quotes"."currency" = 'NGN'),
	CONSTRAINT "delivery_quotes_status_check" CHECK ("delivery_quotes"."status" in ('quoted', 'accepted', 'declined', 'superseded'))
);
--> statement-breakpoint
CREATE TABLE "email_delivery_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"outbox_id" uuid NOT NULL,
	"provider" varchar(80) NOT NULL,
	"provider_event_id" varchar(200) NOT NULL,
	"event_type" varchar(100) NOT NULL,
	"occurred_at" timestamp with time zone NOT NULL,
	"received_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "email_outbox" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"idempotency_key" varchar(180) NOT NULL,
	"event_type" varchar(120) NOT NULL,
	"recipient" varchar(320) NOT NULL,
	"payload" jsonb NOT NULL,
	"status" varchar(20) DEFAULT 'pending' NOT NULL,
	"attempt_count" integer DEFAULT 0 NOT NULL,
	"available_at" timestamp with time zone DEFAULT now() NOT NULL,
	"claimed_until" timestamp with time zone,
	"delivered_at" timestamp with time zone,
	"last_error_code" varchar(80),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "email_outbox_idempotency_key_unique" UNIQUE("idempotency_key"),
	CONSTRAINT "email_outbox_status_check" CHECK ("email_outbox"."status" in ('pending', 'processing', 'sent', 'failed', 'cancelled')),
	CONSTRAINT "email_outbox_attempt_count_nonnegative" CHECK ("email_outbox"."attempt_count" >= 0)
);
--> statement-breakpoint
CREATE TABLE "guest_order_tokens" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"order_id" uuid NOT NULL,
	"token_hash" varchar(64) NOT NULL,
	"issued_at" timestamp with time zone DEFAULT now() NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"revoked_at" timestamp with time zone,
	"replaces_token_id" uuid,
	CONSTRAINT "guest_order_tokens_token_hash_unique" UNIQUE("token_hash"),
	CONSTRAINT "guest_order_tokens_hash_format" CHECK ("guest_order_tokens"."token_hash" ~ '^[0-9a-f]{64}$'),
	CONSTRAINT "guest_order_tokens_ninety_days" CHECK ("guest_order_tokens"."expires_at" = "guest_order_tokens"."issued_at" + interval '90 days')
);
--> statement-breakpoint
CREATE TABLE "order_items" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"order_id" uuid NOT NULL,
	"product_id" uuid NOT NULL,
	"variant_id" uuid NOT NULL,
	"product_name_snapshot" varchar(240) NOT NULL,
	"sku_snapshot" varchar(100) NOT NULL,
	"size_snapshot" varchar(80) NOT NULL,
	"color_snapshot" varchar(100) NOT NULL,
	"unit_price_kobo" bigint NOT NULL,
	"quantity" integer NOT NULL,
	"line_total_kobo" bigint NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "order_items_quantity_positive" CHECK ("order_items"."quantity" > 0),
	CONSTRAINT "order_items_unit_price_nonnegative" CHECK ("order_items"."unit_price_kobo" >= 0),
	CONSTRAINT "order_items_line_total_nonnegative" CHECK ("order_items"."line_total_kobo" >= 0)
);
--> statement-breakpoint
CREATE TABLE "orders" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"checkout_attempt_id" uuid NOT NULL,
	"order_reference" varchar(40) NOT NULL,
	"order_status" varchar(24) DEFAULT 'pending_payment' NOT NULL,
	"fulfilment_status" varchar(24) DEFAULT 'unfulfilled' NOT NULL,
	"customer_name" varchar(240) NOT NULL,
	"customer_email" varchar(320) NOT NULL,
	"customer_phone" varchar(40) NOT NULL,
	"delivery_address" jsonb NOT NULL,
	"product_total_kobo" bigint NOT NULL,
	"accepted_policy_version_id" uuid NOT NULL,
	"accepted_policy_content" text NOT NULL,
	"policy_accepted_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "orders_checkout_attempt_id_unique" UNIQUE("checkout_attempt_id"),
	CONSTRAINT "orders_order_reference_unique" UNIQUE("order_reference"),
	CONSTRAINT "orders_status_check" CHECK ("orders"."order_status" in ('pending_payment', 'paid', 'on_hold', 'cancelled', 'completed')),
	CONSTRAINT "orders_fulfilment_status_check" CHECK ("orders"."fulfilment_status" in ('unfulfilled', 'processing', 'dispatched', 'delivered', 'returned')),
	CONSTRAINT "orders_product_total_nonnegative" CHECK ("orders"."product_total_kobo" >= 0)
);
--> statement-breakpoint
CREATE TABLE "payment_attempts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"order_id" uuid NOT NULL,
	"idempotency_key" varchar(160) NOT NULL,
	"provider" varchar(80) NOT NULL,
	"status" varchar(24) DEFAULT 'created' NOT NULL,
	"amount_kobo" bigint NOT NULL,
	"order_currency" varchar(3) DEFAULT 'NGN' NOT NULL,
	"provider_amount" varchar(100),
	"provider_currency" varchar(3),
	"provider_amount_unit" varchar(80),
	"conversion_basis" jsonb,
	"provider_reference" varchar(180),
	"initiated_at" timestamp with time zone,
	"confirmed_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "payment_attempts_idempotency_key_unique" UNIQUE("idempotency_key"),
	CONSTRAINT "payment_attempts_status_check" CHECK ("payment_attempts"."status" in ('created', 'pending', 'succeeded', 'failed', 'cancelled', 'disputed', 'underpaid', 'on_hold')),
	CONSTRAINT "payment_attempts_amount_nonnegative" CHECK ("payment_attempts"."amount_kobo" >= 0),
	CONSTRAINT "payment_attempts_order_currency_ngn" CHECK ("payment_attempts"."order_currency" = 'NGN'),
	CONSTRAINT "payment_attempts_provider_currency_format" CHECK ("payment_attempts"."provider_currency" is null or "payment_attempts"."provider_currency" ~ '^[A-Z]{3}$'),
	CONSTRAINT "payment_attempts_provider_amount_format" CHECK ("payment_attempts"."provider_amount" is null or "payment_attempts"."provider_amount" ~ '^[0-9]+(\.[0-9]+)?$'),
	CONSTRAINT "payment_attempts_provider_tuple_complete" CHECK ("payment_attempts"."status" = 'created' or ("payment_attempts"."provider_amount" is not null and "payment_attempts"."provider_currency" is not null and "payment_attempts"."provider_amount_unit" is not null and "payment_attempts"."conversion_basis" is not null))
);
--> statement-breakpoint
CREATE TABLE "payment_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"payment_attempt_id" uuid NOT NULL,
	"webhook_event_id" uuid,
	"event_type" varchar(100) NOT NULL,
	"previous_status" varchar(24),
	"next_status" varchar(24) NOT NULL,
	"details" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"recorded_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "policy_drafts" (
	"id" smallint PRIMARY KEY DEFAULT 1 NOT NULL,
	"content" text NOT NULL,
	"updated_by" smallint,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "policy_drafts_singleton_id" CHECK ("policy_drafts"."id" = 1)
);
--> statement-breakpoint
CREATE TABLE "policy_versions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"version_number" integer NOT NULL,
	"content" text NOT NULL,
	"content_sha256" varchar(64) NOT NULL,
	"published_by" smallint,
	"published_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "policy_versions_version_number_unique" UNIQUE("version_number"),
	CONSTRAINT "policy_versions_version_positive" CHECK ("policy_versions"."version_number" > 0),
	CONSTRAINT "policy_versions_sha256_format" CHECK ("policy_versions"."content_sha256" ~ '^[0-9a-f]{64}$')
);
--> statement-breakpoint
CREATE TABLE "product_categories" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"parent_id" uuid,
	"slug" varchar(160) NOT NULL,
	"name" varchar(160) NOT NULL,
	"description" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "product_categories_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "product_media" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"product_id" uuid NOT NULL,
	"storage_key" text NOT NULL,
	"public_url" text NOT NULL,
	"alt_text" varchar(500) NOT NULL,
	"content_type" varchar(120) NOT NULL,
	"byte_size" bigint NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "product_media_storage_key_unique" UNIQUE("storage_key"),
	CONSTRAINT "product_media_byte_size_positive" CHECK ("product_media"."byte_size" > 0)
);
--> statement-breakpoint
CREATE TABLE "product_variants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"product_id" uuid NOT NULL,
	"sku" varchar(100) NOT NULL,
	"size" varchar(80) NOT NULL,
	"color" varchar(100) NOT NULL,
	"color_code" varchar(16),
	"price_kobo" bigint NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "product_variants_sku_unique" UNIQUE("sku"),
	CONSTRAINT "product_variants_price_nonnegative" CHECK ("product_variants"."price_kobo" >= 0)
);
--> statement-breakpoint
CREATE TABLE "products" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"category_id" uuid NOT NULL,
	"slug" varchar(180) NOT NULL,
	"name" varchar(240) NOT NULL,
	"description" text,
	"status" varchar(24) DEFAULT 'draft' NOT NULL,
	"published_at" timestamp with time zone,
	"archived_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "products_slug_unique" UNIQUE("slug"),
	CONSTRAINT "products_status_check" CHECK ("products"."status" in ('draft', 'published', 'archived'))
);
--> statement-breakpoint
CREATE TABLE "provider_webhook_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"payment_attempt_id" uuid,
	"provider" varchar(80) NOT NULL,
	"provider_event_id" varchar(200) NOT NULL,
	"event_type" varchar(160) NOT NULL,
	"payload_sha256" varchar(64) NOT NULL,
	"signature_verified_at" timestamp with time zone,
	"received_at" timestamp with time zone DEFAULT now() NOT NULL,
	"processed_at" timestamp with time zone,
	"processing_status" varchar(24) DEFAULT 'received' NOT NULL,
	"failure_code" varchar(80),
	CONSTRAINT "provider_webhook_events_hash_format" CHECK ("provider_webhook_events"."payload_sha256" ~ '^[0-9a-f]{64}$'),
	CONSTRAINT "provider_webhook_events_status_check" CHECK ("provider_webhook_events"."processing_status" in ('received', 'processing', 'processed', 'failed', 'ignored'))
);
--> statement-breakpoint
CREATE TABLE "refund_attempts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"refund_request_id" uuid NOT NULL,
	"provider" varchar(80) NOT NULL,
	"provider_reference" varchar(180),
	"status" varchar(24) DEFAULT 'pending' NOT NULL,
	"provider_amount" varchar(100),
	"provider_currency" varchar(3),
	"initiated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"confirmed_at" timestamp with time zone,
	CONSTRAINT "refund_attempts_status_check" CHECK ("refund_attempts"."status" in ('pending', 'succeeded', 'failed')),
	CONSTRAINT "refund_attempts_provider_currency_format" CHECK ("refund_attempts"."provider_currency" is null or "refund_attempts"."provider_currency" ~ '^[A-Z]{3}$'),
	CONSTRAINT "refund_attempts_provider_amount_format" CHECK ("refund_attempts"."provider_amount" is null or "refund_attempts"."provider_amount" ~ '^[0-9]+(\.[0-9]+)?$')
);
--> statement-breakpoint
CREATE TABLE "refund_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"refund_request_id" uuid NOT NULL,
	"refund_attempt_id" uuid,
	"event_type" varchar(100) NOT NULL,
	"status" varchar(24) NOT NULL,
	"details" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"recorded_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "refund_requests" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"payment_attempt_id" uuid NOT NULL,
	"idempotency_key" varchar(160) NOT NULL,
	"amount_kobo" bigint NOT NULL,
	"currency" varchar(3) DEFAULT 'NGN' NOT NULL,
	"status" varchar(24) DEFAULT 'requested' NOT NULL,
	"requested_by" smallint NOT NULL,
	"reason" text,
	"requested_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "refund_requests_idempotency_key_unique" UNIQUE("idempotency_key"),
	CONSTRAINT "refund_requests_amount_positive" CHECK ("refund_requests"."amount_kobo" > 0),
	CONSTRAINT "refund_requests_currency_ngn" CHECK ("refund_requests"."currency" = 'NGN'),
	CONSTRAINT "refund_requests_status_check" CHECK ("refund_requests"."status" in ('requested', 'pending', 'succeeded', 'failed', 'cancelled'))
);
--> statement-breakpoint
CREATE TABLE "stock_reservations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"checkout_attempt_id" uuid NOT NULL,
	"order_id" uuid,
	"variant_id" uuid NOT NULL,
	"quantity" integer NOT NULL,
	"status" varchar(24) DEFAULT 'active' NOT NULL,
	"provider_expiry_confirmed_at" timestamp with time zone,
	"released_at" timestamp with time zone,
	"consumed_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "stock_reservations_quantity_positive" CHECK ("stock_reservations"."quantity" > 0),
	CONSTRAINT "stock_reservations_status_check" CHECK ("stock_reservations"."status" in ('active', 'released', 'consumed', 'on_hold'))
);
--> statement-breakpoint
CREATE TABLE "store_settings" (
	"id" smallint PRIMARY KEY DEFAULT 1 NOT NULL,
	"business_name" varchar(200) NOT NULL,
	"support_email" varchar(320),
	"support_phone" varchar(40),
	"support_address" text,
	"support_hours" text,
	"updated_by" smallint,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "store_settings_singleton_id" CHECK ("store_settings"."id" = 1)
);
--> statement-breakpoint
CREATE TABLE "variant_stock" (
	"variant_id" uuid PRIMARY KEY NOT NULL,
	"on_hand" integer DEFAULT 0 NOT NULL,
	"reserved" integer DEFAULT 0 NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "variant_stock_on_hand_nonnegative" CHECK ("variant_stock"."on_hand" >= 0),
	CONSTRAINT "variant_stock_reserved_nonnegative" CHECK ("variant_stock"."reserved" >= 0),
	CONSTRAINT "variant_stock_reserved_within_on_hand" CHECK ("variant_stock"."reserved" <= "variant_stock"."on_hand")
);
--> statement-breakpoint
ALTER TABLE "active_policy" ADD CONSTRAINT "active_policy_policy_version_id_policy_versions_id_fk" FOREIGN KEY ("policy_version_id") REFERENCES "public"."policy_versions"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "active_policy" ADD CONSTRAINT "active_policy_activated_by_admin_users_id_fk" FOREIGN KEY ("activated_by") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "admin_sessions" ADD CONSTRAINT "admin_sessions_admin_user_id_admin_users_id_fk" FOREIGN KEY ("admin_user_id") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_actor_admin_id_admin_users_id_fk" FOREIGN KEY ("actor_admin_id") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "checkout_attempts" ADD CONSTRAINT "checkout_attempts_policy_version_id_policy_versions_id_fk" FOREIGN KEY ("policy_version_id") REFERENCES "public"."policy_versions"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "delivery_payment_events" ADD CONSTRAINT "delivery_payment_events_order_id_orders_id_fk" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "delivery_payment_events" ADD CONSTRAINT "delivery_payment_events_quote_id_delivery_quotes_id_fk" FOREIGN KEY ("quote_id") REFERENCES "public"."delivery_quotes"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "delivery_payment_events" ADD CONSTRAINT "delivery_payment_events_recorded_by_admin_users_id_fk" FOREIGN KEY ("recorded_by") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "delivery_quotes" ADD CONSTRAINT "delivery_quotes_order_id_orders_id_fk" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "delivery_quotes" ADD CONSTRAINT "delivery_quotes_quoted_by_admin_users_id_fk" FOREIGN KEY ("quoted_by") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "email_delivery_events" ADD CONSTRAINT "email_delivery_events_outbox_id_email_outbox_id_fk" FOREIGN KEY ("outbox_id") REFERENCES "public"."email_outbox"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "guest_order_tokens" ADD CONSTRAINT "guest_order_tokens_order_id_orders_id_fk" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "guest_order_tokens" ADD CONSTRAINT "guest_order_tokens_replaces_token_id_guest_order_tokens_id_fk" FOREIGN KEY ("replaces_token_id") REFERENCES "public"."guest_order_tokens"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_order_id_orders_id_fk" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_product_id_products_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_variant_id_product_variants_id_fk" FOREIGN KEY ("variant_id") REFERENCES "public"."product_variants"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "orders" ADD CONSTRAINT "orders_checkout_attempt_id_checkout_attempts_id_fk" FOREIGN KEY ("checkout_attempt_id") REFERENCES "public"."checkout_attempts"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "orders" ADD CONSTRAINT "orders_accepted_policy_version_id_policy_versions_id_fk" FOREIGN KEY ("accepted_policy_version_id") REFERENCES "public"."policy_versions"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_attempts" ADD CONSTRAINT "payment_attempts_order_id_orders_id_fk" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_events" ADD CONSTRAINT "payment_events_payment_attempt_id_payment_attempts_id_fk" FOREIGN KEY ("payment_attempt_id") REFERENCES "public"."payment_attempts"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_events" ADD CONSTRAINT "payment_events_webhook_event_id_provider_webhook_events_id_fk" FOREIGN KEY ("webhook_event_id") REFERENCES "public"."provider_webhook_events"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "policy_drafts" ADD CONSTRAINT "policy_drafts_updated_by_admin_users_id_fk" FOREIGN KEY ("updated_by") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "policy_versions" ADD CONSTRAINT "policy_versions_published_by_admin_users_id_fk" FOREIGN KEY ("published_by") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product_categories" ADD CONSTRAINT "product_categories_parent_id_product_categories_id_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."product_categories"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product_media" ADD CONSTRAINT "product_media_product_id_products_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product_variants" ADD CONSTRAINT "product_variants_product_id_products_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "products" ADD CONSTRAINT "products_category_id_product_categories_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."product_categories"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "provider_webhook_events" ADD CONSTRAINT "provider_webhook_events_payment_attempt_id_payment_attempts_id_fk" FOREIGN KEY ("payment_attempt_id") REFERENCES "public"."payment_attempts"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refund_attempts" ADD CONSTRAINT "refund_attempts_refund_request_id_refund_requests_id_fk" FOREIGN KEY ("refund_request_id") REFERENCES "public"."refund_requests"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refund_events" ADD CONSTRAINT "refund_events_refund_request_id_refund_requests_id_fk" FOREIGN KEY ("refund_request_id") REFERENCES "public"."refund_requests"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refund_events" ADD CONSTRAINT "refund_events_refund_attempt_id_refund_attempts_id_fk" FOREIGN KEY ("refund_attempt_id") REFERENCES "public"."refund_attempts"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refund_requests" ADD CONSTRAINT "refund_requests_payment_attempt_id_payment_attempts_id_fk" FOREIGN KEY ("payment_attempt_id") REFERENCES "public"."payment_attempts"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refund_requests" ADD CONSTRAINT "refund_requests_requested_by_admin_users_id_fk" FOREIGN KEY ("requested_by") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "stock_reservations" ADD CONSTRAINT "stock_reservations_checkout_attempt_id_checkout_attempts_id_fk" FOREIGN KEY ("checkout_attempt_id") REFERENCES "public"."checkout_attempts"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "stock_reservations" ADD CONSTRAINT "stock_reservations_order_id_orders_id_fk" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "stock_reservations" ADD CONSTRAINT "stock_reservations_variant_id_product_variants_id_fk" FOREIGN KEY ("variant_id") REFERENCES "public"."product_variants"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "store_settings" ADD CONSTRAINT "store_settings_updated_by_admin_users_id_fk" FOREIGN KEY ("updated_by") REFERENCES "public"."admin_users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "variant_stock" ADD CONSTRAINT "variant_stock_variant_id_product_variants_id_fk" FOREIGN KEY ("variant_id") REFERENCES "public"."product_variants"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "admin_sessions_user_expiry_idx" ON "admin_sessions" USING btree ("admin_user_id","expires_at");--> statement-breakpoint
CREATE INDEX "admin_sessions_active_expiry_idx" ON "admin_sessions" USING btree ("expires_at") WHERE "admin_sessions"."revoked_at" is null;--> statement-breakpoint
CREATE INDEX "audit_events_entity_idx" ON "audit_events" USING btree ("entity_type","entity_id","occurred_at");--> statement-breakpoint
CREATE INDEX "audit_events_actor_idx" ON "audit_events" USING btree ("actor_admin_id","occurred_at");--> statement-breakpoint
CREATE INDEX "checkout_attempts_status_created_idx" ON "checkout_attempts" USING btree ("status","created_at");--> statement-breakpoint
CREATE INDEX "delivery_payment_events_order_recorded_idx" ON "delivery_payment_events" USING btree ("order_id","recorded_at");--> statement-breakpoint
CREATE INDEX "delivery_quotes_order_created_idx" ON "delivery_quotes" USING btree ("order_id","quoted_at");--> statement-breakpoint
CREATE UNIQUE INDEX "email_delivery_events_provider_event_uq" ON "email_delivery_events" USING btree ("provider","provider_event_id");--> statement-breakpoint
CREATE INDEX "email_delivery_events_outbox_idx" ON "email_delivery_events" USING btree ("outbox_id","received_at");--> statement-breakpoint
CREATE INDEX "email_outbox_pending_idx" ON "email_outbox" USING btree ("available_at","created_at") WHERE "email_outbox"."status" in ('pending', 'processing');--> statement-breakpoint
CREATE UNIQUE INDEX "guest_order_tokens_one_active_per_order_uq" ON "guest_order_tokens" USING btree ("order_id") WHERE "guest_order_tokens"."revoked_at" is null;--> statement-breakpoint
CREATE INDEX "guest_order_tokens_expiry_idx" ON "guest_order_tokens" USING btree ("expires_at") WHERE "guest_order_tokens"."revoked_at" is null;--> statement-breakpoint
CREATE UNIQUE INDEX "order_items_order_variant_uq" ON "order_items" USING btree ("order_id","variant_id");--> statement-breakpoint
CREATE INDEX "order_items_product_idx" ON "order_items" USING btree ("product_id");--> statement-breakpoint
CREATE INDEX "order_items_variant_idx" ON "order_items" USING btree ("variant_id");--> statement-breakpoint
CREATE INDEX "orders_created_idx" ON "orders" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "orders_status_created_idx" ON "orders" USING btree ("order_status","created_at");--> statement-breakpoint
CREATE INDEX "orders_policy_version_idx" ON "orders" USING btree ("accepted_policy_version_id");--> statement-breakpoint
CREATE UNIQUE INDEX "payment_attempts_provider_reference_uq" ON "payment_attempts" USING btree ("provider","provider_reference") WHERE "payment_attempts"."provider_reference" is not null;--> statement-breakpoint
CREATE INDEX "payment_attempts_order_created_idx" ON "payment_attempts" USING btree ("order_id","created_at");--> statement-breakpoint
CREATE INDEX "payment_attempts_reconcile_idx" ON "payment_attempts" USING btree ("status","created_at") WHERE "payment_attempts"."status" in ('pending', 'underpaid', 'on_hold');--> statement-breakpoint
CREATE INDEX "payment_events_attempt_recorded_idx" ON "payment_events" USING btree ("payment_attempt_id","recorded_at");--> statement-breakpoint
CREATE UNIQUE INDEX "payment_events_webhook_uq" ON "payment_events" USING btree ("webhook_event_id") WHERE "payment_events"."webhook_event_id" is not null;--> statement-breakpoint
CREATE INDEX "product_categories_parent_active_idx" ON "product_categories" USING btree ("parent_id","is_active");--> statement-breakpoint
CREATE INDEX "product_media_product_idx" ON "product_media" USING btree ("product_id","sort_order");--> statement-breakpoint
CREATE UNIQUE INDEX "product_variants_product_size_color_uq" ON "product_variants" USING btree ("product_id","size","color");--> statement-breakpoint
CREATE INDEX "product_variants_product_active_idx" ON "product_variants" USING btree ("product_id","is_active");--> statement-breakpoint
CREATE INDEX "products_category_status_idx" ON "products" USING btree ("category_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "provider_webhook_events_provider_id_uq" ON "provider_webhook_events" USING btree ("provider","provider_event_id");--> statement-breakpoint
CREATE INDEX "provider_webhook_events_attempt_idx" ON "provider_webhook_events" USING btree ("payment_attempt_id");--> statement-breakpoint
CREATE UNIQUE INDEX "refund_attempts_provider_reference_uq" ON "refund_attempts" USING btree ("provider","provider_reference") WHERE "refund_attempts"."provider_reference" is not null;--> statement-breakpoint
CREATE INDEX "refund_attempts_refund_idx" ON "refund_attempts" USING btree ("refund_request_id","initiated_at");--> statement-breakpoint
CREATE INDEX "refund_events_request_recorded_idx" ON "refund_events" USING btree ("refund_request_id","recorded_at");--> statement-breakpoint
CREATE INDEX "refund_requests_payment_status_idx" ON "refund_requests" USING btree ("payment_attempt_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "stock_reservations_checkout_variant_uq" ON "stock_reservations" USING btree ("checkout_attempt_id","variant_id");--> statement-breakpoint
CREATE INDEX "stock_reservations_variant_status_idx" ON "stock_reservations" USING btree ("variant_id","status");--> statement-breakpoint
CREATE INDEX "stock_reservations_active_created_idx" ON "stock_reservations" USING btree ("created_at") WHERE "stock_reservations"."status" = 'active';