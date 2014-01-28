class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super
    if params[:address]
      address = Address.create(params[:address])
      address.line1 = resource.first_name
      resource.address = address
      resource.save!
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

  def update_address
    user = User.find(params[:id])
    user.address_from_cpr
    redirect_to edit_user_registration_path
  end

  def new_library
  end

  def after_inactive_sign_up_path_for(resource)
    user_wait_mail_path
  end
end
