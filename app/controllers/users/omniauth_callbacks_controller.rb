class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::CasServer::SessionsControllerBehaviour

  def facebook
    omniauth_common
  end

  def linkedin
    omniauth_common
  end

  def google_oauth2
    omniauth_common
  end

  def omniauth_common
    user = User.login_from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      sign_in_and_redirect user, :event => :authentication
    else
      redirect_to root_url
    end
  end
end
