class Account < ApplicationRecord
  belongs_to :tenant
  has_many   :users, dependent: :restrict_with_error
  has_many   :account_notes, dependent: :destroy

  validates :name, presence: true
  validates :status, inclusion: { in: %w[active suspended closed] }
  validates :branding_color_hex,
            format: { with: /\A#?[0-9A-Fa-f]{6}\z/, allow_blank: true }
end
