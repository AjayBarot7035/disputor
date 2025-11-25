require "test_helper"

class EvidenceTest < ActiveSupport::TestCase
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require dispute" do
    evidence = Evidence.new
    assert_not evidence.valid?
    assert_includes evidence.errors[:dispute], "must exist"
  end
end

