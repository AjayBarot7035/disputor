require "test_helper"

class DailyVolumeReportTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "America/New_York"
    )
  end

  test "should calculate daily volume for date range" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    
    # Create disputes on different days
    dispute1 = Dispute.create!(
      charge: charge,
      external_id: "dsp_1",
      amount_cents: 1000,
      currency: "USD",
      opened_at: 2.days.ago,
      status: "open"
    )
    
    dispute2 = Dispute.create!(
      charge: charge,
      external_id: "dsp_2",
      amount_cents: 2000,
      currency: "USD",
      opened_at: 2.days.ago,
      status: "open"
    )
    
    dispute3 = Dispute.create!(
      charge: charge,
      external_id: "dsp_3",
      amount_cents: 1500,
      currency: "USD",
      opened_at: 1.day.ago,
      status: "open"
    )

    from_date = 3.days.ago.to_date
    to_date = Time.current.to_date

    report = DailyVolumeReport.new(@user, from_date, to_date)
    data = report.generate

    assert data.is_a?(Array)
    assert data.length >= 2
    
    # Check that amounts are summed correctly
    day_data = data.find { |d| d[:date] == dispute1.opened_at.in_time_zone(@user.time_zone).to_date }
    assert_not_nil day_data
    assert_equal 2, day_data[:count]
    assert_equal 3000, day_data[:total_amount_cents]
  end

  test "should default to last 30 days if no dates provided" do
    report = DailyVolumeReport.new(@user, nil, nil)
    assert_not_nil report.from_date
    assert_not_nil report.to_date
  end

  test "should respect user time zone" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    
    # Create dispute at a specific UTC time that might fall on different days in different time zones
    dispute = Dispute.create!(
      charge: charge,
      external_id: "dsp_1",
      amount_cents: 1000,
      currency: "USD",
      opened_at: Time.utc(2024, 1, 1, 5, 0, 0), # 5 AM UTC = midnight EST
      status: "open"
    )

    report = DailyVolumeReport.new(@user, Date.new(2024, 1, 1), Date.new(2024, 1, 1))
    data = report.generate

    # Should group by date in user's time zone
    assert data.any? { |d| d[:date] == Date.new(2024, 1, 1) }
  end
end

