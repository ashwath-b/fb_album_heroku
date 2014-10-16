class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_token
  	Koala::Facebook::API.new(current_user.oauth_token) if session[:user_id]
  end

  def confirm_logged_in
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'sessions', :action => 'login')
      return false
    else
      flash[:notice] = nil
      return true
    end
  end

  helper_method :current_user, :current_token
end
