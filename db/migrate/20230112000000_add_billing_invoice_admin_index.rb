class AddBillingInvoiceAdminIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  # Speeds up the admin-side "all open invoices" view.
  def change
    return unless table_exists?(:billing_invoices)
    return if index_exists?(:billing_invoices, :status, name: 'idx_billing_invoices_status_admin')
    add_index :billing_invoices, :status,
              algorithm: :concurrently,
              name: 'idx_billing_invoices_status_admin',
              where: "status IN ('open', 'finalized')"
  end
end
