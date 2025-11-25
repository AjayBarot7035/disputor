class Charge < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[USD] }
end

