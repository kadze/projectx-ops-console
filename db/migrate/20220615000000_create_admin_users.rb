class CreateAdminUsers < ActiveRecord::Migration[6.1]
  # Internal staff accounts. Distinct from the `users` table (which is
  # tenant-scoped customer users). admin_users have no tenant_id and
  # belong to the operating company.

  def change
    create_table :admin_users do |t|
      t.text   :email,           null: false
      t.text   :password_digest
      t.string :role,            null: false, default: 'support'
      t.string :status,          null: false, default: 'active'
      t.datetime :last_login_at
      t.timestamps
    end
    add_index :admin_users, 'lower(email)', unique: true, name: 'uniq_admin_users_email_lower'
  end
end
