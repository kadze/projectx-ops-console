class AcknowledgeSplit < ActiveRecord::Migration[6.1]
  # Adds a `migration_source` column to admin_audit_policies so we can
  # see at-a-glance which Rails-side policy rows were created via this
  # migration vs. by the data-team's hand-loading script.
  #
  # While I'm here:
  #
  # The Rails/Flyway split keeps biting us. Adding this column is
  # the kind of change that genuinely belongs in Rails (it's a
  # column on a table only ops-console reads or writes). Almost every
  # other migration we've added on the Rails side in the last six
  # months has been a billing-table column that should arguably have
  # gone through Flyway. We've talked about a hard rule: "any column
  # on a Flyway-managed table goes via Flyway." We agree with the
  # rule. We have not enforced it.
  #                                                          — Priya
  def change
    return unless table_exists?(:admin_audit_policies)
    return if column_exists?(:admin_audit_policies, :migration_source)
    add_column :admin_audit_policies, :migration_source, :string,
               default: 'rails-migration', null: false
  end
end
