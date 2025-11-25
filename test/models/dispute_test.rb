require "test_helper"

class DisputeTest < ActiveSupport::TestCase
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require charge" do
    dispute = Dispute.new
    assert_not dispute.valid?
    assert_includes dispute.errors[:charge], "must exist"
  end

  test "should require external_id" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.new(charge: charge, amount_cents: 1000, currency: "USD")
    assert_not dispute.valid?
    assert_includes dispute.errors[:external_id], "can't be blank"
  end

  test "should require unique external_id" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    dispute = Dispute.new(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    assert_not dispute.valid?
    assert_includes dispute.errors[:external_id], "has already been taken"
  end

  test "should have default status of open" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    assert dispute.open?
  end

  test "should require amount_cents" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.new(charge: charge, external_id: "dsp_123", currency: "USD")
    assert_not dispute.valid?
    assert_includes dispute.errors[:amount_cents], "can't be blank"
  end

  test "should require amount_cents to be greater than zero" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.new(charge: charge, external_id: "dsp_123", amount_cents: 0, currency: "USD")
    assert_not dispute.valid?
    assert_includes dispute.errors[:amount_cents], "must be greater than 0"
  end

  test "should require currency" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.new(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: nil)
    assert_not dispute.valid?
    assert_includes dispute.errors[:currency], "can't be blank"
  end

  test "should only allow USD currency" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.new(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "EUR")
    assert_not dispute.valid?
    assert_includes dispute.errors[:currency], "is not included in the list"
  end

  test "should require opened_at" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.new(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: nil)
    assert_not dispute.valid?
    assert_includes dispute.errors[:opened_at], "can't be blank"
  end

  test "should transition from open to needs_evidence" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    
    result = dispute.transition_to("needs_evidence", actor: user, note: "Need more evidence")
    
    assert result
    assert dispute.needs_evidence?
  end

  test "should transition from needs_evidence to awaiting_decision" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current, status: "needs_evidence")
    
    result = dispute.transition_to("awaiting_decision", actor: user, note: "Evidence collected")
    
    assert result
    assert dispute.awaiting_decision?
  end

  test "should transition from awaiting_decision to won" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current, status: "awaiting_decision")
    
    result = dispute.transition_to("won", actor: user, note: "Dispute won")
    
    assert result
    assert dispute.won?
  end

  test "should transition from awaiting_decision to lost" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current, status: "awaiting_decision")
    
    result = dispute.transition_to("lost", actor: user, note: "Dispute lost")
    
    assert result
    assert dispute.lost?
  end

  test "should reject invalid transition from open to won" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    
    result = dispute.transition_to("won", actor: user, note: "Invalid transition")
    
    assert_not result
    assert dispute.open?
  end

  test "should set closed_at when transitioning to won" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current, status: "awaiting_decision")
    
    dispute.transition_to("won", actor: user, note: "Dispute won")
    
    assert_not_nil dispute.closed_at
  end

  test "should set closed_at when transitioning to lost" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current, status: "awaiting_decision")
    
    dispute.transition_to("lost", actor: user, note: "Dispute lost")
    
    assert_not_nil dispute.closed_at
  end

  test "should reopen dispute from won status" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current, status: "awaiting_decision")
    dispute.transition_to("won", actor: user, note: "Dispute won")
    
    result = dispute.reopen(actor: user, justification: "New evidence found")
    
    assert result
    assert dispute.reopened?
  end

  test "should reopen dispute from lost status" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current, status: "awaiting_decision")
    dispute.transition_to("lost", actor: user, note: "Dispute lost")
    
    result = dispute.reopen(actor: user, justification: "Appeal filed")
    
    assert result
    assert dispute.reopened?
  end

  test "should not reopen dispute from open status" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    
    result = dispute.reopen(actor: user, justification: "Cannot reopen")
    
    assert_not result
    assert dispute.open?
  end

  test "should create CaseAction when transitioning status" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    
    assert_difference "CaseAction.count", 1 do
      dispute.transition_to("needs_evidence", actor: user, note: "Need more evidence")
    end
    
    case_action = CaseAction.last
    assert_equal dispute, case_action.dispute
    assert_equal user, case_action.actor
    assert_equal "status_transition", case_action.action
    assert_equal "Need more evidence", case_action.note
  end
end

