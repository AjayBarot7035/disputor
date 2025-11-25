require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new session" do
    get new_session_url
    assert_response :success
  end

  test "should sign in with valid credentials" do
    user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )

    post sessions_url, params: { session: { email: "admin@example.com", password: "password123" } }
    
    assert_redirected_to root_url
    assert_equal user.id, session[:user_id]
  end

  test "should not sign in with invalid credentials" do
    user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )

    post sessions_url, params: { session: { email: "admin@example.com", password: "wrongpassword" } }
    
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should sign out" do
    user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )

    post sessions_url, params: { session: { email: "admin@example.com", password: "password123" } }
    assert_equal user.id, session[:user_id]

    delete session_url(user.id)
    
    assert_redirected_to new_session_url
    assert_nil session[:user_id]
  end
end

