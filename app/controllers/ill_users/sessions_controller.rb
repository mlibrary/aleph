class IllUsers::SessionsController < Devise::SessionsController
  include Devise::CasServer::SessionsControllerBehaviour

  def new
    @login_template = 'library'
    super
  end

  def after_sign_in_path_for(resource)
    resource.aleph_borrower
    return show_ill_user_registration_path unless authenticating_aleph?
    super
  end

  def destroy
    sign_out_all_scopes
    super
    flash.clear
  end

  def show
    authenticate_ill_user!
    render :text => 'Hello'
  end

  private

  def authenticating_aleph?
    aleph_url? session[:cas_server_service]
  end

  helper_method :aleph_url?
  def aleph_url?(url)
    aleph_urls = [Rails.application.config.aleph[:url], Rails.application.config.aleph[:alternate_urls]].flatten
    url && aleph_urls.any? { |aleph_url| url.start_with?(aleph_url) }
  end
end
