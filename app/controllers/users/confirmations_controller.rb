class Users::ConfirmationsController < Devise::ConfirmationsController

  # Show page that tells users to find mail and click link
  def wait_mail
  end

  # Show page that tells users that email is confirmed and they should edit
  def confirmed
  end

  def after_confirmation_path_for(resource_name, resource)
    #pending_after_sign_in_path = session[:pending_after_sign_in_path]
    sign_in(resource)
    #session[:pending_after_sign_in_path] = pending_after_sign_in_path

    show_user_registration_path
  end

end
