class CreateAdminSessions < ActiveRecord::Migration[6.1]
  # ops-console-only. Tracks staff sessions (impersonation history,
  # IP, etc.). Not in Flyway — never needed by other services.

  def change
    create_table :admin_sessions do |t|
      t.bigint   :admin_user_id, null: false
      t.string   :ip_address
      t.string   :user_agent
      t.datetime :created_at,    null: false
      t.datetime :expires_at,    null: false
      t.datetime :revoked_at
    end
    add_index :admin_sessions, :admin_user_id
    add_index :admin_sessions, :expires_at
  end
end
