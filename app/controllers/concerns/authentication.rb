module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :current_user, :signed_in?
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def require_authentication
    unless signed_in?
      redirect_to new_session_url, alert: "Please sign in to continue"
    end
  end
end

