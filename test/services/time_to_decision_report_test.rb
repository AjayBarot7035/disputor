require "test_helper"

class TimeToDecisionReportTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "admin@example.com",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )
  end

  test "should calculate p50 and p90 for closed disputes" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")
    system_user = User.create!(
      email: "system@disputor.local",
      password: "password123",
      role: :admin,
      time_zone: "UTC"
    )

    # Create disputes with different durations
    opened_at = 1.week.ago
    dispute1 = Dispute.create!(
      charge: charge,
      external_id: "dsp_1",
      amount_cents: 1000,
      currency: "USD",
      opened_at: opened_at,
      status: "awaiting_decision"
    )
    dispute1.transition_to("won", actor: system_user, note: "Test")
    dispute1.update_column(:closed_at, opened_at + 1.day) # 1 day duration

    dispute2 = Dispute.create!(
      charge: charge,
      external_id: "dsp_2",
      amount_cents: 1000,
      currency: "USD",
      opened_at: opened_at,
      status: "awaiting_decision"
    )
    dispute2.transition_to("won", actor: system_user, note: "Test")
    dispute2.update_column(:closed_at, opened_at + 2.days) # 2 days duration

    dispute3 = Dispute.create!(
      charge: charge,
      external_id: "dsp_3",
      amount_cents: 1000,
      currency: "USD",
      opened_at: opened_at,
      status: "awaiting_decision"
    )
    dispute3.transition_to("won", actor: system_user, note: "Test")
    dispute3.update_column(:closed_at, opened_at + 3.days) # 3 days duration

    report = TimeToDecisionReport.new
    data = report.generate

    assert data.is_a?(Array)
    assert data.length > 0

    week_data = data.find { |d| d[:week] == opened_at.beginning_of_week }
    assert_not_nil week_data
    assert_equal 3, week_data[:count]
    assert_not_nil week_data[:p50]
    assert_not_nil week_data[:p90]
  end

  test "should only include closed disputes" do
    charge = Charge.create!(external_id: "chg_123", amount_cents: 1000, currency: "USD")

    # Create open dispute
    Dispute.create!(
      charge: charge,
      external_id: "dsp_open",
      amount_cents: 1000,
      currency: "USD",
      opened_at: 1.week.ago,
      status: "open"
    )

    report = TimeToDecisionReport.new
    data = report.generate

    # Should not include open disputes
    assert data.all? { |d| d[:count] > 0 }
  end
end
