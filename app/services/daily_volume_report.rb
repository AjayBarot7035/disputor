class DailyVolumeReport
  attr_reader :user, :from_date, :to_date

  def initialize(user, from_date = nil, to_date = nil)
    @user = user
    @from_date = from_date || 30.days.ago.beginning_of_day
    @to_date = to_date || Time.current.end_of_day
  end

  def generate
    # Convert to user's time zone
    from = from_date.in_time_zone(user.time_zone)
    to = to_date.in_time_zone(user.time_zone)

    # Group disputes by day in user's time zone
    disputes = Dispute.where(opened_at: from..to)
    
    disputes.group_by { |d| d.opened_at.in_time_zone(user.time_zone).to_date }
      .map do |date, day_disputes|
        {
          date: date,
          count: day_disputes.count,
          total_amount_cents: day_disputes.sum(&:amount_cents)
        }
      end
      .sort_by { |d| d[:date] }
  end

  def to_json
    generate.map { |d| d.merge(date: d[:date].iso8601, total_amount: d[:total_amount_cents] / 100.0) }
  end
end

