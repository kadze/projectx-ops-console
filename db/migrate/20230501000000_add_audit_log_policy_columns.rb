class AddAuditLogPolicyColumns < ActiveRecord::Migration[6.1]
  def change
    return unless table_exists?(:admin_audit_policies)
    return if column_exists?(:admin_audit_policies, :slack_channel)
    add_column :admin_audit_policies, :slack_channel, :string
    add_column :admin_audit_policies, :alert_threshold, :integer, default: 0, null: false
  end
end
