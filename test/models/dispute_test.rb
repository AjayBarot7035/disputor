require "test_helper"

class DisputeTest < ActiveSupport::TestCase
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require charge" do
    dispute = Dispute.new
    assert_not dispute.valid?
    assert_includes dispute.errors[:charge], "must exist"
  end
end

