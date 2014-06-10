class IllUsers::SessionsController < Devise::SessionsController
  include Devise::CasServer::SessionsControllerBehaviour

  def new
    @login_template = 'library'
    super
  end

  def after_sign_in_path_for(resource)
    resource.aleph_borrower
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

end
