class Users::RegistrationsController < Devise::RegistrationsController
  def update_address
    user = User.find(params[:id])
    user.address_from_cpr
    redirect_to edit_user_registration_path
  end
end
