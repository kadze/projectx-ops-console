# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_04_06_000000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "account_notes", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "admin_user_id"
    t.text "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_account_notes_on_account_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.text "name", null: false
    t.string "status", limit: 16, default: "active", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.bigint "billing_address_id"
    t.text "branding_logo_url"
    t.string "branding_color_hex", limit: 7
    t.index ["billing_address_id"], name: "idx_accounts_billing_address_id"
    t.index ["tenant_id"], name: "idx_accounts_tenant_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.text "line1", null: false
    t.text "line2"
    t.text "city", null: false
    t.string "region", limit: 64
    t.string "postal_code", limit: 32
    t.string "country", limit: 2, default: "US", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.index ["tenant_id"], name: "idx_addresses_tenant_id"
  end

  create_table "admin_audit_policies", force: :cascade do |t|
    t.string "action_pattern", null: false
    t.string "verbosity", default: "normal", null: false
    t.boolean "active", default: true, null: false
    t.text "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slack_channel"
    t.integer "alert_threshold", default: 0, null: false
    t.string "migration_source", default: "rails-migration", null: false
    t.index ["action_pattern"], name: "index_admin_audit_policies_on_action_pattern", unique: true
  end

  create_table "admin_sessions", force: :cascade do |t|
    t.bigint "admin_user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "revocation_reason"
    t.index ["admin_user_id"], name: "index_admin_sessions_on_admin_user_id"
    t.index ["expires_at"], name: "index_admin_sessions_on_expires_at"
  end

  create_table "admin_users", force: :cascade do |t|
    t.text "email", null: false
    t.text "password_digest"
    t.string "role", default: "support", null: false
    t.string "status", default: "active", null: false
    t.datetime "last_login_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "lower(email)", name: "uniq_admin_users_email_lower", unique: true
    t.index ["last_login_at"], name: "index_admin_users_on_last_login_at"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.text "name", null: false
    t.text "token_digest", null: false
    t.text "scopes", null: false, array: true
    t.bigint "created_by_user_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "revoked_at"
    t.index ["token_digest"], name: "uniq_api_tokens_digest", unique: true
  end

  create_table "audit_log", force: :cascade do |t|
    t.bigint "actor_user_id"
    t.text "actor_label"
    t.string "action", limit: 64, null: false
    t.string "target_type", limit: 64
    t.bigint "target_id"
    t.jsonb "payload", default: {}, null: false
    t.datetime "recorded_at", default: -> { "now()" }, null: false
    t.index ["actor_user_id"], name: "idx_audit_log_actor_user_id", where: "(actor_user_id IS NOT NULL)"
    t.index ["recorded_at"], name: "idx_audit_log_recorded_at"
    t.index ["target_type", "target_id"], name: "idx_audit_log_target"
  end

  create_table "billing_adjustments", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "amount_cents", null: false
    t.text "reason", null: false
    t.bigint "created_by_user_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "adjustment_type", limit: 32, default: "manual", null: false
    t.index ["invoice_id"], name: "idx_billing_adjustments_invoice_id"
  end

  create_table "billing_disputes", force: :cascade do |t|
    t.bigint "billing_invoice_id", null: false
    t.bigint "raised_by_admin_id"
    t.string "status", default: "open", null: false
    t.bigint "amount_cents"
    t.text "reason"
    t.datetime "resolved_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["billing_invoice_id"], name: "index_billing_disputes_on_billing_invoice_id"
    t.index ["status"], name: "index_billing_disputes_on_status"
  end

  create_table "billing_invoices", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.date "period_start", null: false
    t.date "period_end", null: false
    t.bigint "total_cents", default: 0, null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.string "status", limit: 16, default: "open", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "finalized_at"
    t.jsonb "metadata", default: {}, null: false
    t.date "due_date"
    t.datetime "issued_at"
    t.index ["account_id", "period_start", "period_end"], name: "uniq_billing_invoices_account_period_open", unique: true, where: "((status)::text = 'open'::text)"
    t.index ["account_id"], name: "idx_billing_invoices_account_id"
    t.index ["due_date"], name: "idx_billing_invoices_due_date", where: "((status)::text <> ALL ((ARRAY['paid'::character varying, 'void'::character varying])::text[]))"
    t.index ["status"], name: "idx_billing_invoices_status_admin", where: "((status)::text = ANY ((ARRAY['open'::character varying, 'finalized'::character varying])::text[]))"
    t.check_constraint "((status)::text <> 'finalized'::text) OR (finalized_at IS NOT NULL)", name: "billing_invoices_finalized_at_required"
  end

  create_table "carrier_codes", primary_key: "code", id: { type: :string, limit: 16 }, force: :cascade do |t|
    t.text "display_name", null: false
    t.boolean "supports_tracking", default: true, null: false
  end

  create_table "carrier_events_raw", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "carrier_code", limit: 16, null: false
    t.text "raw_body", null: false
    t.text "signature"
    t.datetime "received_at", default: -> { "now()" }, null: false
    t.boolean "processed", default: false, null: false
    t.datetime "processed_at"
    t.text "process_error"
    t.jsonb "metadata", default: {}, null: false
    t.index "((metadata ->> 'carrier_account_id'::text))", name: "idx_carrier_events_raw_metadata_account", where: "(metadata ? 'carrier_account_id'::text)"
    t.index ["received_at"], name: "idx_carrier_events_raw_received_at"
    t.index ["received_at"], name: "idx_carrier_events_raw_unprocessed", where: "(processed = false)"
  end

  create_table "legacy_export_runs", force: :cascade do |t|
    t.text "triggered_by", null: false
    t.datetime "run_started_at", default: -> { "now()" }, null: false
    t.datetime "run_completed_at"
    t.bigint "rows_exported"
    t.string "status", limit: 16, default: "started", null: false
    t.text "error"
    t.index ["run_started_at"], name: "idx_legacy_export_runs_started_at"
  end

  create_table "route_calculations", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "shipment_ids", null: false, array: true
    t.jsonb "result", null: false
    t.string "solver_version", limit: 32, null: false
    t.bigint "duration_ms"
    t.datetime "computed_at", default: -> { "now()" }, null: false
    t.bigint "account_id"
    t.jsonb "solver_metadata", default: {}, null: false
    t.integer "version", default: 1, null: false
    t.index ["account_id"], name: "idx_route_calculations_account_id"
    t.index ["computed_at"], name: "idx_route_calculations_computed_at"
    t.index ["shipment_ids"], name: "idx_route_calculations_shipment_ids_gin", using: :gin
    t.index ["tenant_id"], name: "idx_route_calculations_tenant_id"
    t.index ["version"], name: "idx_route_calculations_version"
  end

  create_table "route_optimization_jobs", force: :cascade do |t|
    t.text "sqs_message_id"
    t.bigint "shipment_ids", null: false, array: true
    t.string "status", limit: 16, default: "queued", null: false
    t.datetime "enqueued_at", default: -> { "now()" }, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.bigint "route_calculation_id"
    t.text "error"
    t.index ["enqueued_at"], name: "idx_route_optimization_jobs_enqueued_at"
    t.index ["status"], name: "idx_route_optimization_jobs_status"
  end

  create_table "shipment_events", force: :cascade do |t|
    t.bigint "shipment_id", null: false
    t.string "event_type", limit: 64, null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "recorded_at", default: -> { "now()" }, null: false
    t.index ["occurred_at"], name: "idx_shipment_events_occurred_at"
    t.index ["shipment_id"], name: "idx_shipment_events_shipment_id"
    t.check_constraint "(event_type)::text = ANY ((ARRAY['created'::character varying, 'label_generated'::character varying, 'pickup_scheduled'::character varying, 'picked_up'::character varying, 'in_transit'::character varying, 'out_for_delivery'::character varying, 'delivered'::character varying, 'delivery_attempted'::character varying, 'delivery_failed'::character varying, 'returned'::character varying, 'cancelled'::character varying, 'note_added'::character varying])::text[])", name: "shipment_events_event_type_known"
  end

  create_table "shipment_status_history", force: :cascade do |t|
    t.bigint "shipment_id", null: false
    t.string "from_status", limit: 32
    t.string "to_status", limit: 32, null: false
    t.bigint "changed_by_user_id"
    t.text "note"
    t.datetime "changed_at", default: -> { "now()" }, null: false
    t.index ["shipment_id", "changed_at"], name: "idx_status_history_shipment_id_changed_at_desc", order: { changed_at: :desc }
    t.index ["shipment_id"], name: "idx_status_history_shipment_id"
  end

  create_table "shipment_status_types", primary_key: "code", id: { type: :string, limit: 32 }, force: :cascade do |t|
    t.text "description", null: false
    t.boolean "terminal", default: false, null: false
  end

  create_table "shipments", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "account_id", null: false
    t.decimal "weight_kg", precision: 10, scale: 3
    t.string "status", limit: 32, default: "created", null: false
    t.string "carrier_code", limit: 16
    t.text "tracking_number"
    t.datetime "expected_delivery_at"
    t.datetime "delivered_at"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.bigint "quoted_amount_cents"
    t.string "quoted_currency", limit: 3
    t.text "customer_notes"
    t.bigint "origin_address_id"
    t.bigint "destination_address_id"
    t.text "internal_notes"
    t.text "label_url"
    t.datetime "label_generated_at"
    t.jsonb "metadata", default: {}, null: false
    t.string "internal_status"
    t.bigint "created_by_admin_id"
    t.index ["account_id", "status"], name: "idx_shipments_account_status"
    t.index ["account_id"], name: "idx_shipments_account_id"
    t.index ["carrier_code", "tracking_number"], name: "uniq_shipments_carrier_tracking", unique: true, where: "((carrier_code IS NOT NULL) AND (tracking_number IS NOT NULL))"
    t.index ["created_by_admin_id"], name: "index_shipments_on_created_by_admin_id"
    t.index ["destination_address_id"], name: "idx_shipments_destination_address_id"
    t.index ["metadata"], name: "idx_shipments_metadata_gin", opclass: :jsonb_path_ops, using: :gin
    t.index ["origin_address_id"], name: "idx_shipments_origin_address_id"
    t.index ["status"], name: "idx_shipments_status"
    t.index ["tenant_id"], name: "idx_shipments_tenant_id"
    t.index ["updated_at"], name: "idx_shipments_open", where: "((status)::text <> ALL ((ARRAY['delivered'::character varying, 'cancelled'::character varying, 'returned'::character varying])::text[]))"
  end

  create_table "support_ticket_comments", force: :cascade do |t|
    t.bigint "support_ticket_id", null: false
    t.bigint "admin_user_id"
    t.bigint "user_id"
    t.text "body", null: false
    t.boolean "internal", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["support_ticket_id"], name: "index_support_ticket_comments_on_support_ticket_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "account_id"
    t.bigint "assigned_admin_id"
    t.string "status", default: "open", null: false
    t.string "subject", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["status"], name: "index_support_tickets_on_status"
    t.index ["tenant_id"], name: "index_support_tickets_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.text "name", null: false
    t.string "slug", limit: 64, null: false
    t.string "billing_plan", limit: 32, default: "standard", null: false
    t.string "status", limit: 16, default: "active", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["billing_plan"], name: "index_tenants_on_billing_plan"
    t.index ["slug"], name: "tenants_slug_key", unique: true
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.uuid "jwt_id", null: false
    t.inet "ip_addr"
    t.text "user_agent"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.index ["jwt_id"], name: "uniq_user_sessions_jwt_id", unique: true
    t.index ["user_id"], name: "idx_user_sessions_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "account_id"
    t.text "email", null: false
    t.text "password_digest"
    t.string "role", limit: 32, default: "member", null: false
    t.string "status", limit: 16, default: "active", null: false
    t.datetime "last_login_at"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.string "phone", limit: 32
    t.text "internal_notes"
    t.index "lower(btrim(email))", name: "uniq_users_email_lower_btrim", unique: true
    t.index ["account_id"], name: "idx_users_account_id"
    t.index ["tenant_id"], name: "idx_users_tenant_id"
    t.check_constraint "(role)::text = ANY ((ARRAY['admin'::character varying, 'member'::character varying, 'viewer'::character varying])::text[])", name: "users_role_check"
  end

  add_foreign_key "accounts", "addresses", column: "billing_address_id", name: "accounts_billing_address_id_fkey"
  add_foreign_key "accounts", "tenants", name: "accounts_tenant_id_fkey"
  add_foreign_key "addresses", "tenants", name: "addresses_tenant_id_fkey"
  add_foreign_key "api_tokens", "users", column: "created_by_user_id", name: "api_tokens_created_by_user_id_fkey"
  add_foreign_key "audit_log", "users", column: "actor_user_id", name: "audit_log_actor_user_id_fkey"
  add_foreign_key "billing_adjustments", "billing_invoices", column: "invoice_id", name: "billing_adjustments_invoice_id_fkey"
  add_foreign_key "billing_adjustments", "users", column: "created_by_user_id", name: "billing_adjustments_created_by_user_id_fkey"
  add_foreign_key "billing_invoices", "accounts", name: "billing_invoices_account_id_fkey"
  add_foreign_key "carrier_events_raw", "carrier_codes", column: "carrier_code", primary_key: "code", name: "carrier_events_raw_carrier_code_fkey"
  add_foreign_key "route_calculations", "accounts", name: "route_calculations_account_id_fkey"
  add_foreign_key "route_calculations", "tenants", name: "route_calculations_tenant_id_fkey"
  add_foreign_key "route_optimization_jobs", "route_calculations", name: "route_optimization_jobs_route_calculation_id_fkey"
  add_foreign_key "shipment_events", "shipments", name: "shipment_events_shipment_id_fkey"
  add_foreign_key "shipment_status_history", "shipment_status_types", column: "from_status", primary_key: "code", name: "shipment_status_history_from_status_fkey"
  add_foreign_key "shipment_status_history", "shipment_status_types", column: "to_status", primary_key: "code", name: "shipment_status_history_to_status_fkey"
  add_foreign_key "shipment_status_history", "shipments", name: "shipment_status_history_shipment_id_fkey"
  add_foreign_key "shipment_status_history", "users", column: "changed_by_user_id", name: "shipment_status_history_changed_by_user_id_fkey"
  add_foreign_key "shipments", "accounts", name: "shipments_account_id_fkey"
  add_foreign_key "shipments", "addresses", column: "destination_address_id", name: "shipments_destination_address_id_fkey"
  add_foreign_key "shipments", "addresses", column: "origin_address_id", name: "shipments_origin_address_id_fkey"
  add_foreign_key "shipments", "carrier_codes", column: "carrier_code", primary_key: "code", name: "shipments_carrier_code_fkey"
  add_foreign_key "shipments", "shipment_status_types", column: "status", primary_key: "code", name: "shipments_status_fkey"
  add_foreign_key "shipments", "tenants", name: "shipments_tenant_id_fkey"
  add_foreign_key "user_sessions", "users", name: "user_sessions_user_id_fkey"
  add_foreign_key "users", "accounts", name: "users_account_id_fkey"
  add_foreign_key "users", "tenants", name: "users_tenant_id_fkey"
end
