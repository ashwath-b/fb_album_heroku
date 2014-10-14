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
    if current_user
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
    else
      redirect_to root_url
    end
  end

  def photos
    if current_user
    # redirect_to :action => 'login' if !current_user
      @graph = current_token
      @count = current_user.photo_links
      @pics = @graph.get_connections(params["album_id"],'photos')
    else
      redirect_to root_url
    end
  end

  def import
    if current_user
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
      # redirect_to root_url, flash: { errors: flash[:errors], frm: 'import' } if !flash[:errors].nil?
    else
      redirect_to root_url 
    end
  end

  def home 
    redirect_to :action => 'login' if !current_user
    @links = current_user.photo_links if current_user
    @err_msg = params[:err_msg] if current_user
  end

  def edit
    redirect_to :action => 'login' if !current_user
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
      flash[:errors] = "No Photos were selected"
      flash[:notice] = nil
    else
      flash[:notice] = "Deleted #{i} photos"
      flash[:errors] = nil
    end
    redirect_to root_url, flash: { notice: flash[:notice], frm: 'delete' } if !flash[:notice].nil?
    redirect_to root_url, flash: { errors: flash[:errors], frm: 'delete' } if !flash[:errors].nil?
    # redirect_to(:action => 'home', :err => flash[:errors], :suc => flash[:notice], :frm => 'delete')
  end

  def login
    redirect_to :action => 'home' if current_user
  end

end
