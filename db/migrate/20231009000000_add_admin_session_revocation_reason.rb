class AddAdminSessionRevocationReason < ActiveRecord::Migration[6.1]
  def change
    return if column_exists?(:admin_sessions, :revocation_reason)
    add_column :admin_sessions, :revocation_reason, :string
  end
end
