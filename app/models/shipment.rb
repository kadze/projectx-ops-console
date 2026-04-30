class Shipment < ApplicationRecord
  # SOLE-WRITER ASSUMPTION (legacy):
  # When this model was written, ops-console was the only writer to the
  # `shipments` table. Today, shipments-api also writes (and is the
  # primary writer for new shipments). The validations + callbacks below
  # were authored under the sole-writer assumption and were retrofitted
  # later — visibly — to coexist with shipments-api-created rows.
  #
  # See routebox-platform-docs/notes/handover.md and
  # routebox-db-migrations/docs/schema-ownership.md.

  belongs_to :tenant
  belongs_to :account

  # ops-console-private state machine on top of the shared `status`
  # column. Driven by a before_save callback below.
  INTERNAL_STATUSES = %w[
    none
    flagged_for_review
    on_hold
    under_dispute
    resolved
  ].freeze

  validates :status, presence: true

  # Originally we required created_by_admin_id on every row — at the
  # time, every row was created here. shipments-api-created rows have
  # nil. We retrofit by skipping the validation when shipments-api
  # almost certainly wrote the row.
  validate :require_created_by_admin_id, unless: :likely_shipments_api_authored?

  before_save :set_internal_status_default

  scope :authored_by_admin, ->        { where.not(created_by_admin_id: nil) }
  scope :authored_by_shipments_api, -> { where(created_by_admin_id: nil) }

  private

  def require_created_by_admin_id
    return if created_by_admin_id.present?
    errors.add(:created_by_admin_id, "is required for ops-console-authored shipments")
  end

  # The retrofit. The heuristic is "if it has no admin id and was
  # already persisted, assume shipments-api wrote it." This is fine
  # for updates from ops-console on a shipments-api-authored row;
  # it does the wrong thing if an admin tries to CREATE a shipment
  # without setting created_by_admin_id (that's a guard-rail loss).
  # We've never had an admin do that. Yet.
  def likely_shipments_api_authored?
    persisted? && created_by_admin_id.nil?
  end

  def set_internal_status_default
    self.internal_status ||= 'none'
  end
end
