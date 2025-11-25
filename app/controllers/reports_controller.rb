class ReportsController < ApplicationController
  def daily_volume
    from_date = parse_date(params[:from]) || 30.days.ago.beginning_of_day
    to_date = parse_date(params[:to]) || Time.current.end_of_day

    # Convert to user's time zone
    from_date = from_date.in_time_zone(current_user.time_zone)
    to_date = to_date.in_time_zone(current_user.time_zone)

    # Group disputes by day in user's time zone
    disputes = Dispute.where(opened_at: from_date..to_date)
    
    @daily_data = disputes.group_by { |d| d.opened_at.in_time_zone(current_user.time_zone).to_date }
      .map do |date, day_disputes|
        {
          date: date,
          count: day_disputes.count,
          total_amount_cents: day_disputes.sum(&:amount_cents)
        }
      end
      .sort_by { |d| d[:date] }

    respond_to do |format|
      format.html
      format.json { render json: { data: @daily_data.map { |d| d.merge(date: d[:date].iso8601, total_amount: d[:total_amount_cents] / 100.0) } } }
    end
  end

  def time_to_decision
    # Get all closed disputes (won or lost)
    closed_disputes = Dispute.where(status: [:won, :lost])
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
    @weekly_data = durations.group_by { |d| d[:week] }
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

    respond_to do |format|
      format.html
      format.json { render json: { data: @weekly_data.map { |d| d.merge(week: d[:week].iso8601) } } }
    end
  end

  private

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  def percentile(sorted_array, percentile)
    return nil if sorted_array.empty?
    
    index = (percentile / 100.0) * (sorted_array.length - 1)
    lower = sorted_array[index.floor]
    upper = sorted_array[index.ceil]
    
    lower + (upper - lower) * (index - index.floor)
  end
end

