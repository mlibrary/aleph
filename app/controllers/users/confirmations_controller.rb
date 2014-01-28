class Users::ConfirmationsController < Devise::ConfirmationsController

  # Show page that tells users to find mail and click link
  def wait_mail
  end

  # Show page that tells users that email is confirmed and they should edit
  def confirmed
  end

  def after_confirmation_path_for(resource_name, resource)
    user_confirmed_path
  end

end
