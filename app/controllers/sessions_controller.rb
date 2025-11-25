class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    
    if user&.authenticate(params[:session][:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Signed in successfully"
    else
      render :new, status: :unprocessable_entity, alert: "Invalid email or password"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_session_url, notice: "Signed out successfully"
  end
end

