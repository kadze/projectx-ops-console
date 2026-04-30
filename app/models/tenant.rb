class Tenant < ApplicationRecord
  has_many :accounts, dependent: :restrict_with_error
  has_many :users,    dependent: :restrict_with_error

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :status, inclusion: { in: %w[active suspended closed] }
  validates :billing_plan, inclusion: { in: %w[trial standard enterprise] }
end
