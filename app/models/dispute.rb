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

  def transition_to(new_status, actor:, note: nil, details: {})
    return false unless valid_transition?(new_status)

    old_status = status
    self.closed_at = Time.current if ["won", "lost"].include?(new_status)
    update(status: new_status)
    true
  end

  def valid_transition?(new_status)
    case status
    when "open"
      ["needs_evidence", "awaiting_decision"].include?(new_status)
    when "needs_evidence"
      ["awaiting_decision", "open"].include?(new_status)
    when "awaiting_decision"
      ["won", "lost"].include?(new_status)
    else
      false
    end
  end
end
