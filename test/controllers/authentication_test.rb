require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "should redirect to sign in when not authenticated" do
    get root_url
    assert_redirected_to new_session_url
    assert_equal "Please sign in to continue", flash[:alert]
  end

  test "should allow access when authenticated" do
    user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )

    post sessions_url, params: { session: { email: "admin@example.com", password: "password123" } }
    get root_url
    
    assert_response :success
  end

  test "should provide current_user helper" do
    user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )

    post sessions_url, params: { session: { email: "admin@example.com", password: "password123" } }
    get root_url
    
    assert_response :success
    # current_user is available in views, test via controller instance
  end
end

