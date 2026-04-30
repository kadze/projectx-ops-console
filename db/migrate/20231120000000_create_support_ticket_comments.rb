class CreateSupportTicketComments < ActiveRecord::Migration[6.1]
  def change
    create_table :support_ticket_comments do |t|
      t.bigint   :support_ticket_id, null: false
      t.bigint   :admin_user_id
      t.bigint   :user_id  # if the customer commented
      t.text     :body, null: false
      t.boolean  :internal, null: false, default: false
      t.timestamps
    end
    add_index :support_ticket_comments, :support_ticket_id
  end
end
