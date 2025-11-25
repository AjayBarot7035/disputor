class Dispute < ApplicationRecord
  belongs_to :charge

  enum :status, {
    open: "open",
    needs_evidence: "needs_evidence",
    awaiting_decision: "awaiting_decision",
    won: "won",
    lost: "lost",
    reopened: "reopened"
  }

  validates :external_id, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[USD] }
  validates :opened_at, presence: true
end

