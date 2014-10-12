class User < ActiveRecord::Base

	has_many :photo_links
  def self.from_omniauth(auth)
    # p "Comin in omniauth function"
    user = where(provider: auth.provider, uid: auth.uid).first
    if user
      # p "Updating the user!!!"
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
    else
      user = User.new
      # p "Creating the User!!!!"
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
    end
    user.save!
    user
  end

end
