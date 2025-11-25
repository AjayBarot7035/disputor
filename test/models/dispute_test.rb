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
    Dispute.create!(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.new(charge: charge, external_id: "dsp_123", amount_cents: 1000, currency: "USD")
    assert_not dispute.valid?
    assert_includes dispute.errors[:external_id], "has already been taken"
  end
end

