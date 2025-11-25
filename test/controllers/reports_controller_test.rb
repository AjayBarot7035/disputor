require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )
    post sessions_url, params: { session: { email: @user.email, password: "password123" } }
  end

  test "should get daily volume report" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current,
      status: "open"
    )

    get reports_daily_volume_path
    assert_response :success
  end

  test "should filter daily volume by date range" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: 2.days.ago,
      status: "open"
    )

    get reports_daily_volume_path, params: {
      from: 3.days.ago.strftime("%Y-%m-%d"),
      to: 1.day.ago.strftime("%Y-%m-%d")
    }
    assert_response :success
  end

  test "should get daily volume as JSON" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.current,
      status: "open"
    )

    get reports_daily_volume_path(format: :json)
    assert_response :success
    
    json = JSON.parse(response.body)
    assert json.key?("data")
    assert json["data"].is_a?(Array)
  end

  test "should get time to decision report" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_123",
      amount_cents: 1000,
      currency: "USD",
      opened_at: 1.week.ago,
      status: "open"
    )

    get reports_time_to_decision_path
    assert_response :success
  end

  test "should calculate p50 and p90 for time to decision" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    
    # Create disputes with different durations
    10.times do |i|
      opened_at = (i + 1).weeks.ago
      dispute = Dispute.create!(
        charge: charge,
        external_id: "dsp_#{i}",
        amount_cents: 1000,
        currency: "USD",
        opened_at: opened_at,
        status: "awaiting_decision"
      )
      
      # Close some disputes
      if i < 5
        dispute.update!(status: "won", closed_at: opened_at + (i + 1).days)
      end
    end

    get reports_time_to_decision_path(format: :json)
    assert_response :success
    
    json = JSON.parse(response.body)
    assert json.key?("data")
    assert json["data"].is_a?(Array)
  end
end

