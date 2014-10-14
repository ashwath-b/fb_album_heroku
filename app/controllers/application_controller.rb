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

  # def authenticate_example!
  #   p "coming appl"
  #   if !current_user
  #     redirect_to(:controller => 'session', :action => 'login')
  #   end
  # end

  helper_method :current_user, :current_token
end
