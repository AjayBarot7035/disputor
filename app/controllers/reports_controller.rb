class ReportsController < ApplicationController
  def daily_volume
    from_date = parse_date(params[:from])
    to_date = parse_date(params[:to])
    
    report = DailyVolumeReport.new(current_user, from_date, to_date)
    @daily_data = report.generate

    respond_to do |format|
      format.html
      format.json { render json: { data: report.to_json } }
    end
  end

  def time_to_decision
    report = TimeToDecisionReport.new
    @weekly_data = report.generate

    respond_to do |format|
      format.html
      format.json { render json: { data: report.to_json } }
    end
  end

  private

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end
end
