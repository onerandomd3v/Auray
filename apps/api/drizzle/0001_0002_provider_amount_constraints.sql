ALTER TABLE "payment_attempts" DROP CONSTRAINT "payment_attempts_provider_tuple_complete";--> statement-breakpoint
ALTER TABLE "payment_attempts" ADD CONSTRAINT "payment_attempts_provider_tuple_complete" CHECK ("payment_attempts"."status" = 'created' or ("payment_attempts"."provider_amount" is not null and "payment_attempts"."provider_currency" is not null and "payment_attempts"."provider_amount_unit" is not null and ("payment_attempts"."provider_currency" = 'NGN' or "payment_attempts"."conversion_basis" is not null)));
--> statement-breakpoint
CREATE FUNCTION auray_reject_immutable_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% rows are append-only', TG_TABLE_NAME USING ERRCODE = '55000';
END;
$$;
--> statement-breakpoint
CREATE TRIGGER order_items_append_only BEFORE UPDATE OR DELETE ON order_items FOR EACH ROW EXECUTE FUNCTION auray_reject_immutable_mutation();
--> statement-breakpoint
CREATE TRIGGER policy_versions_append_only BEFORE UPDATE OR DELETE ON policy_versions FOR EACH ROW EXECUTE FUNCTION auray_reject_immutable_mutation();
--> statement-breakpoint
CREATE TRIGGER audit_events_append_only BEFORE UPDATE OR DELETE ON audit_events FOR EACH ROW EXECUTE FUNCTION auray_reject_immutable_mutation();
--> statement-breakpoint
CREATE TRIGGER payment_events_append_only BEFORE UPDATE OR DELETE ON payment_events FOR EACH ROW EXECUTE FUNCTION auray_reject_immutable_mutation();
--> statement-breakpoint
CREATE TRIGGER refund_events_append_only BEFORE UPDATE OR DELETE ON refund_events FOR EACH ROW EXECUTE FUNCTION auray_reject_immutable_mutation();
--> statement-breakpoint
CREATE TRIGGER delivery_payment_events_append_only BEFORE UPDATE OR DELETE ON delivery_payment_events FOR EACH ROW EXECUTE FUNCTION auray_reject_immutable_mutation();
--> statement-breakpoint
CREATE TRIGGER email_delivery_events_append_only BEFORE UPDATE OR DELETE ON email_delivery_events FOR EACH ROW EXECUTE FUNCTION auray_reject_immutable_mutation();
