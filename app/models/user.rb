class User < ApplicationRecord
  belongs_to :tenant
  belongs_to :account, optional: true

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role,   inclusion: { in: %w[admin member viewer] }
  validates :status, inclusion: { in: %w[active suspended closed] }
end
