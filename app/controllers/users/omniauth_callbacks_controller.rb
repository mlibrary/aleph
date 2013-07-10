class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    omniauth_common
  end

  def omniauth_common
    auth = request.env["omniauth.auth"]
    identity = Identity.find_with_omniauth(auth)

    if !identity
      private_id = UserType.find_by_code('private').id
      user = User.where(:email => auth.info.email, :user_type_id =>
        private_id).first
      user = User.create_from_omniauth(auth, private_id) if !user

      identity = Identity.create(uid: auth.uid, provider:auth.provider, user_id: user.id)
      identity.save!
    else
      user = identity.user
    end
    if user.persisted?
      sign_in_and_redirect user, :event => :authentication
    else
      redirect_to root_url
    end
  end
end
