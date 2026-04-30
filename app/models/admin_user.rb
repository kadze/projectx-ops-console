class AdminUser < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role,  inclusion: { in: %w[admin support readonly billing] }
  validates :status, inclusion: { in: %w[active suspended] }
end
