class AddBillingPlanIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  # The billing-monthly job hits this every night and the seq scan was
  # showing up in pg_stat_statements. Adding concurrently because the
  # tenants table is hot (writes from ops-console; reads from everyone).
  def change
    return if index_exists?(:tenants, :billing_plan)
    add_index :tenants, :billing_plan, algorithm: :concurrently
  end
end
