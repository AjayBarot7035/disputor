require "test_helper"

class CaseActionTest < ActiveSupport::TestCase
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require dispute" do
    case_action = CaseAction.new
    assert_not case_action.valid?
    assert_includes case_action.errors[:dispute], "must exist"
  end

  test "should require actor" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    case_action = CaseAction.new(dispute: dispute)
    assert_not case_action.valid?
    assert_includes case_action.errors[:actor], "must exist"
  end

  test "should require action" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD", opened_at: Time.current)
    user = User.create!(email: "admin@example.com", password: "password123", role: :admin)
    case_action = CaseAction.new(dispute: dispute, actor: user)
    assert_not case_action.valid?
    assert_includes case_action.errors[:action], "can't be blank"
  end
end

