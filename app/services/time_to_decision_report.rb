class TimeToDecisionReport
  def generate
    # Get all closed disputes (won or lost)
    closed_disputes = Dispute.where(status: [ :won, :lost ])
      .where.not(closed_at: nil)
      .where.not(opened_at: nil)

    # Calculate duration for each dispute
    durations = closed_disputes.map do |dispute|
      duration_days = (dispute.closed_at - dispute.opened_at) / 1.day
      {
        dispute: dispute,
        duration_days: duration_days,
        week: dispute.opened_at.beginning_of_week
      }
    end

    # Group by week
    durations.group_by { |d| d[:week] }
      .map do |week, week_durations|
        durations_only = week_durations.map { |d| d[:duration_days] }.sort
        p50 = percentile(durations_only, 50)
        p90 = percentile(durations_only, 90)

        {
          week: week,
          count: week_durations.count,
          p50: p50,
          p90: p90
        }
      end
      .sort_by { |d| d[:week] }
  end

  def to_json
    generate.map { |d| d.merge(week: d[:week].iso8601) }
  end

  private

  def percentile(sorted_array, percentile)
    return nil if sorted_array.empty?

    index = (percentile / 100.0) * (sorted_array.length - 1)
    lower = sorted_array[index.floor]
    upper = sorted_array[index.ceil]

    lower + (upper - lower) * (index - index.floor)
  end
end
