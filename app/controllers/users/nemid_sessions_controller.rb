require 'dtubase'

class Users::NemidSessionsController < Devise::DkNemidSessionsController
  def new
    flash[:error] = Array.new
    accepted = true
    %w{payment_terms printed_terms}.each do |term|
      if params["accept_#{term}"] != '1'
        accepted = false
      end
    end
    if accepted
      sign_out(:dk_nemid)
      super
    else
      flash[:error] << I18n.t('riyosha.edit.must_accept_terms')
      redirect_to show_user_registration_path
    end
  end

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
      user.aleph_borrower
    else
      logger.error "DkNemIdUser #{resource.inspect} already assgned to user #{user.inspect}."
      flash[:error] << I18n.t('riyosha.edit.cpr_already_assigned')
    end
    show_user_registration_path
  end

  def destroy
    super
    flash.clear
  end

  def auth_options
    super.merge({:recall => "users/registrations#show"})
  end
end
