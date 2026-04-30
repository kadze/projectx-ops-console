class AddAccountBranding < ActiveRecord::Migration[6.1]
  # Adds branding_logo_url + branding_color_hex to accounts.
  # ops-console exclusively writes these (they're surfaced in the
  # customer-facing portal via a read-through join from shipments-api).
  #
  # CROSS-POLLINATION ALERT:
  # routebox-db-migrations/flyway/sql/V041__coordinate_with_rails_account_branding.sql
  # mirrors this migration with `IF NOT EXISTS` clauses so flyway repair
  # against a populated DB stays sane. Keep the column shape in sync
  # if either side changes.
  #
  # Long-term: stop letting Rails write columns that other services
  # depend on. We've said this for a while.

  def change
    return unless table_exists?(:accounts)
    unless column_exists?(:accounts, :branding_logo_url)
      add_column :accounts, :branding_logo_url, :text
    end
    unless column_exists?(:accounts, :branding_color_hex)
      add_column :accounts, :branding_color_hex, :string, limit: 7
    end
  end
end
