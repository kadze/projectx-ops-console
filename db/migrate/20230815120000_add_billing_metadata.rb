class AddBillingMetadata < ActiveRecord::Migration[6.1]
  # Adds a `metadata` jsonb column to billing_invoices and
  # billing_adjustments. ops-console writes these tables; the column
  # also needs to be readable from shipments-api for invoice-shipment
  # cross-references on the customer-portal billing view.
  #
  # CROSS-POLLINATION ALERT:
  # routebox-db-migrations/flyway/sql/V020__add_billing_metadata.sql
  # mirrors this migration with `IF NOT EXISTS` clauses so it's a
  # no-op against any DB where this Rails migration already ran. We
  # write the column shape in BOTH places because:
  #   - this Rails migration is what actually adds the column in any
  #     environment that runs ops-console first
  #   - V020 makes the column visible to Flyway's tracking so a
  #     `flyway repair` against a populated DB doesn't get confused
  # If you change the column shape here, change V020 to match.

  def change
    return unless table_exists?(:billing_invoices)
    unless column_exists?(:billing_invoices, :metadata)
      add_column :billing_invoices, :metadata, :jsonb, null: false, default: {}
    end
    return unless table_exists?(:billing_adjustments)
    unless column_exists?(:billing_adjustments, :metadata)
      add_column :billing_adjustments, :metadata, :jsonb, null: false, default: {}
    end
  end
end
