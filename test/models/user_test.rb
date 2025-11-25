require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Disable fixtures for TDD
  def self.fixtures(*args); end

  test "should require email" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    User.create!(email: "test@example.com", password: "password123")
    user = User.new(email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "should require valid email format" do
    user = User.new(email: "invalid-email")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "should require password" do
    user = User.new(email: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should have default role of read_only" do
    user = User.create!(email: "test@example.com", password: "password123")
    assert user.read_only?
  end
end

