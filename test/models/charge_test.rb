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

  test "should require amount_cents" do
    charge = Charge.new(external_id: "chg_123", currency: "USD")
    assert_not charge.valid?
    assert_includes charge.errors[:amount_cents], "can't be blank"
  end

  test "should require amount_cents to be greater than zero" do
    charge = Charge.new(external_id: "chg_123", amount_cents: 0, currency: "USD")
    assert_not charge.valid?
    assert_includes charge.errors[:amount_cents], "must be greater than 0"
  end

  test "should require currency" do
    charge = Charge.new(external_id: "chg_123", amount_cents: 1000, currency: nil)
    assert_not charge.valid?
    assert_includes charge.errors[:currency], "can't be blank"
  end

  test "should only allow USD currency" do
    charge = Charge.new(external_id: "chg_123", amount_cents: 1000, currency: "EUR")
    assert_not charge.valid?
    assert_includes charge.errors[:currency], "is not included in the list"
  end
end

