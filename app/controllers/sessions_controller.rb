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
    @graph = current_token
    @count = current_user.photo_links
    @pics = @graph.get_connections(params["album_id"],'photos')
  end

  def import
    flash[:errors] = nil
    data = params[:photo_links]
    num_photos = current_user.photo_links.count
    if num_photos < 10
      data.each do |k,v|
        if v == '1' && num_photos < 10
          photo_link = PhotoLink.new(:user_id => current_user.id, :link => k) 
          if photo_link.valid?
            photo_link.save!
            num_photos += 1
          else
            flash[:errors] = "One of the photos was a duplicate" unless photo_link.errors.messages.nil?
          end
        end
      end
    end
    if num_photos >= 10
      flash[:notice] = "You can have maximum of TEN photos"
    else
      flash[:notice] = nil
    end
    @links = current_user.photo_links if current_user
    render 'home'
  end

  def home
    @links = current_user.photo_links if current_user
  end

  def edit
    @photos = current_user.photo_links if current_user
  end

  def delete
    data = params[:photo_links]
    i = 0;
    data.each do |k,v|
      if v == '1'
        photo_link = PhotoLink.where(:link => k).first
        photo_link.delete
        i += 1
      end
    end
    if i == 0
      flash[:errors] = "You did not select any Photos"
      flash[:notice] = nil
    else
      flash[:notice] = "Successfully deleted #{i} photos"
      flash[:errors] = nil
    end
    @links = current_user.photo_links if current_user
    render 'home'
  end

end
