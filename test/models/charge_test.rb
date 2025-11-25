require "test_helper"

class ChargeTest < ActiveSupport::TestCase
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require external_id" do
    charge = Charge.new
    assert_not charge.valid?
    assert_includes charge.errors[:external_id], "can't be blank"
  end

  test "should require unique external_id" do
    Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    charge = Charge.new(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    assert_not charge.valid?
    assert_includes charge.errors[:external_id], "has already been taken"
  end
end

