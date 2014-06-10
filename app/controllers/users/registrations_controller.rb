class Users::RegistrationsController < Devise::RegistrationsController

  def create
    super
    session[:pending_after_sign_in_path] = params[:service]
    if params[:address]
      address = Address.create(params[:address])
      address.line1 = resource.first_name
      resource.address = address
      resource.save!
    end
  end

  def show
    if request.env['warden'].user(:ill_user)
      sign_out(:user) if request.env['warden'].user(:user)
      redirect_to show_ill_user_registration_path and return
    end
    
    authenticate_scope!
    if session[:pending_after_sign_in_path] && resource.may_lend_printed?
      logger.info "Pending after_sign_in_path found in session and user may lend printed materials. Redirecting to pending path."
      resource.aleph_borrower
      redirect_to session.delete(:pending_after_sign_in_path) and return
    end
  end

  def update_resource(resource, account_update_params)
    if account_update_params[:address]
      resource.address.update_attributes(account_update_params[:address])
      result = resource.address.save
      account_update_params.delete(:address)
    end
    super && result
  end

  def after_inactive_sign_up_path_for(resource)
    user_wait_mail_path
  end


end
