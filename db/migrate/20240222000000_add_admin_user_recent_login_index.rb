class AddAdminUserRecentLoginIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return unless table_exists?(:admin_users)
    return if index_exists?(:admin_users, :last_login_at)
    add_index :admin_users, :last_login_at, algorithm: :concurrently
  end
end
