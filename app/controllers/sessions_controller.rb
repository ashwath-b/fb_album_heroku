class SessionsController < ApplicationController
  
  before_action :confirm_logged_in, :except => [:login, :destroy, :create]

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
      @album_list = @graph.get_connections("me", "albums")
  end

  def photos
      @graph = current_token
      @pics = @graph.get_connections(params["album_id"],'photos')
      @links = []
      @pics.each do |data|
        hash = {}
        hash['link'] = data['images'][0]["source"]
        @links << hash
      end
  end

  def import
    data = params[:photo_links]
    flash[:errors] = nil
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
      flash[:notice] = "Maximum of TEN photos Allowed"
    else
      flash[:notice] = nil
    end
    redirect_to root_url, flash: { notice: flash[:notice], errors: flash[:errors] } 
  end

  def home 
    @links = current_user.photo_links if current_user
    num = @links.count
    @err_msg = params[:err_msg] if current_user
  end

  def edit
    @links = current_user.photo_links if current_user
  end

  def delete
    data = params[:photo_links]
    i = 0
    data.each do |k,v|
      if v == '1'
        photo_link = PhotoLink.where(:link => k).first
        photo_link.delete
        i += 1
      end
    end
    if i == 0
      flash[:errors] = "No Photos were selected"
      flash[:notice] = nil
    else
      flash[:notice] = "Deleted #{i} photos"
      flash[:errors] = nil
    end
    redirect_to root_url, flash: { notice: flash[:notice], errors: flash[:errors] }
    # redirect_to(:action => 'home', :err => flash[:errors], :suc => flash[:notice], :frm => 'delete')
  end

  def login
    redirect_to :action => 'home' if current_user
  end

  def update
    # Just doing it for tesing the merging process
  end
end
