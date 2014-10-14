class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    session[:fb_token] = nil
    redirect_to root_url
  end

  def albums
    # @graph = Koala::Facebook::API.new(current_user.oauth_token)
    @graph = current_token
    pho = @graph.get_connections("me", "albums")
    @format = []
    pho.each do |l|
      hash = {}
      hash["id"] = l["id"]
      hash["link"] = l["link"]
      hash["name"] = l["name"]
      hash["count"] = l["count"]
      @format << hash
    end
  end

  def photos
    # @graph = Koala::Facebook::API.new(current_user.oauth_token)
    @graph = current_token
    @count = current_user.photo_links
    @pics = @graph.get_connections(params["album_id"],'photos')
  end

  def import
    p params
    @err = []
    data = params[:sessions]
    data.each do |k,v|
      if v == '1'
        photo_link = PhotoLink.new(:user_id => current_user.id, :link => k) 
        photo_link.save! if photo_link.valid?
        @err << photo_link.errors.messages
      end
    end
    p @err
    redirect_to(:action => 'home', :err_msg => @err)
  end

  def home 
    @links = current_user.photo_links if current_user
    @err_msg = params[:err_msg] if current_user
  end
end
