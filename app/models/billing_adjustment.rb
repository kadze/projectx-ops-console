class BillingAdjustment < ApplicationRecord
  belongs_to :billing_invoice, foreign_key: :invoice_id

  validates :amount_cents, presence: true
  validates :reason, presence: true
end
