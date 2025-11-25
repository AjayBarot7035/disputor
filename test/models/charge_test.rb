require "test_helper"

class ChargeTest < ActiveSupport::TestCase
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require external_id" do
    charge = Charge.new
    assert_not charge.valid?
    assert_includes charge.errors[:external_id], "can't be blank"
  end
end

