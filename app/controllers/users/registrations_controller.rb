class Users::RegistrationsController < Devise::RegistrationsController
  def update_address
    user = User.find(params[:id])
    user.address_from_cpr
    redirect_to edit_user_registration_path
  end

  protected

  # Add flash messasges for missing requirements for lending
  def update_resource(resource, account_update_params)
    result = super
    if resource.respond_to?(:requirements_for_lending_printed) &&
       is_flashing_format?
      flash[:error] = Array.new
      requirements = resource.requirements_for_lending_printed
      unless requirements.nil?
        requirements.each do |requirement|
          flash[:error] << I18n.t('riyosha.edit.need.accept') + requirement
        end
      end
    end
    result
  end

end
