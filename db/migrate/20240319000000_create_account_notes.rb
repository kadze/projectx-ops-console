class CreateAccountNotes < ActiveRecord::Migration[6.1]
  # Free-form internal notes on an account. Only readable to admin_users.
  def change
    create_table :account_notes do |t|
      t.bigint   :account_id,    null: false
      t.bigint   :admin_user_id
      t.text     :body,          null: false
      t.timestamps
    end
    add_index :account_notes, :account_id
  end
end
