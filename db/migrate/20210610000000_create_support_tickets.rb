class CreateSupportTickets < ActiveRecord::Migration[6.1]
  def change
    create_table :support_tickets do |t|
      t.bigint   :tenant_id,  null: false
      t.bigint   :account_id
      t.bigint   :assigned_admin_id
      t.string   :status, null: false, default: 'open'
      t.string   :subject, null: false
      t.text     :body
      t.timestamps
    end
    add_index :support_tickets, :tenant_id
    add_index :support_tickets, :status
  end
end
