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

  test "should have default time_zone of UTC" do
    user = User.create!(email: "test@example.com", password: "password123")
    assert_equal "UTC", user.time_zone
  end

  test "admin? should return true for admin role" do
    user = User.new(role: :admin)
    assert user.admin?
  end

  test "reviewer? should return true for reviewer role" do
    user = User.new(role: :reviewer)
    assert user.reviewer?
  end

  test "can_edit? should return true for admin and reviewer" do
    admin = User.new(role: :admin)
    reviewer = User.new(role: :reviewer)
    read_only = User.new(role: :read_only)

    assert admin.can_edit?
    assert reviewer.can_edit?
    assert_not read_only.can_edit?
  end

  test "can_manage_users? should return true only for admin" do
    admin = User.new(role: :admin)
    reviewer = User.new(role: :reviewer)
    read_only = User.new(role: :read_only)

    assert admin.can_manage_users?
    assert_not reviewer.can_manage_users?
    assert_not read_only.can_manage_users?
  end
end

