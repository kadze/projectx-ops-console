class CreateBillingDisputes < ActiveRecord::Migration[6.1]
  # ops-console-only. We track customer disputes against an invoice
  # separately so the billing rollups can ignore disputed amounts.

  def change
    create_table :billing_disputes do |t|
      t.bigint   :billing_invoice_id, null: false
      t.bigint   :raised_by_admin_id
      t.string   :status, null: false, default: 'open'
      t.bigint   :amount_cents
      t.text     :reason
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :billing_disputes, :billing_invoice_id
    add_index :billing_disputes, :status
  end
end
