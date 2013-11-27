require 'dtubase'

class Users::NemidSessionsController < Devise::DkNemidSessionsController

  # Devise doen't return in create function, so can't add code after
  # a super call.
  # So this seems to be the best place to link users together.

  def after_sign_in_path_for(resource)
    if resource.user.nil?
      # Map to the current user in user scope
      user = env['warden'].user(:user)
      if user.nil?
        # The user logged into the session has expired
        # We need to relogin to complete the process.
        # TODO: Make sure proper message is displayed.
        throw(:warden)
      end

      resource.user = user
      resource.save!

      # Add user address based on cpr.
      user.address_from_cpr
    end
    # Redirect to the user edit form where they can accept terms.
    edit_user_registration_path
  end

  def destroy
    super
    flash.clear
  end

end
