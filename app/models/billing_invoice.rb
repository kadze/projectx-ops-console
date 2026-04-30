class BillingInvoice < ApplicationRecord
  belongs_to :account
  has_many   :billing_adjustments, dependent: :destroy
  has_many   :billing_disputes,    dependent: :destroy

  validates :status, inclusion: { in: %w[open finalized paid void] }
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, length: { is: 3 }

  scope :open_for_admin, -> {
    where(status: %w[open finalized])
  }
end
