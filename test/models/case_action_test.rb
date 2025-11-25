require "test_helper"

class CaseActionTest < ActiveSupport::TestCase
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require dispute" do
    case_action = CaseAction.new
    assert_not case_action.valid?
    assert_includes case_action.errors[:dispute], "must exist"
  end
end

