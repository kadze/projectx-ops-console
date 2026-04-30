class CreateAdminAuditPolicies < ActiveRecord::Migration[6.1]
  # ops-console-only. The policies table that drives which admin actions
  # write to audit_log and at what verbosity level.

  def change
    create_table :admin_audit_policies do |t|
      t.string  :action_pattern, null: false
      t.string  :verbosity,      null: false, default: 'normal'
      t.boolean :active,         null: false, default: true
      t.text    :note
      t.timestamps
    end
    add_index :admin_audit_policies, :action_pattern, unique: true
  end
end
