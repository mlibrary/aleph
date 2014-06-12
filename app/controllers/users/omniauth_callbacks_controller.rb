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

  def after_sign_in_path_for(resource) 
    resource.aleph_borrower
    if authenticating_aleph? && !resource.may_lend_printed? 
      logger.info "Authentication request is from Aleph and user may not lend printed materials. Storing after_sign_in_path in session."
      session[:pending_after_sign_in_path] = super
      show_user_registration_path
    else 
      super
    end
  end

  helper_method :authenticating_aleph?
  def authenticating_aleph?
    aleph_url? session[:cas_server_service]
  end

  helper_method :aleph_url?
  def aleph_url? url
    aleph_urls = [Rails.application.config.aleph[:url], Rails.application.config.aleph[:alternate_urls]].flatten
    url && aleph_urls.any?{|aleph_url| url.start_with?(aleph_url)}
  end

end
