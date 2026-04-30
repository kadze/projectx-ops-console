class AuditLog < ApplicationRecord
  # NOTE: this table is in Flyway, not Rails. We talk to it from here as
  # an ActiveRecord model anyway because Rails' query builder is
  # convenient. Don't add Rails-side migrations against this table —
  # those go in routebox-db-migrations.
  self.table_name = 'audit_log'

  validates :action, presence: true

  def self.append!(actor:, action:, target_type: nil, target_id: nil, payload: {})
    create!(
      actor_user_id: actor.is_a?(Integer) ? actor : actor&.id,
      actor_label:   actor.respond_to?(:audit_label) ? actor.audit_label : nil,
      action:        action,
      target_type:   target_type,
      target_id:     target_id,
      payload:       payload,
      recorded_at:   Time.current,
    )
  end
end
