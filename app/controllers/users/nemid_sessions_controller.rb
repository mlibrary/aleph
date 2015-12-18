require 'dtubase'
module Users
  #
  class NemidSessionsController < Devise::DkNemidSessionsController
    #def new
    def create
      flash[:error] = []
      flash[:error] << I18n.t('riyosha.edit.must_accept_terms') unless terms_accepted?
      flash[:error] << I18n.t('riyosha.edit.cprs_dont_match') unless cprs_match?
      flash[:error] << I18n.t('riyosha.edit.cpr_invalid_format') unless cprs_valid?

      if flash[:error].empty?
        sign_out(:dk_nemid)
        super #redirect_to create_dk_nemid_user_session_path(cpr: params['cpr'])
      else
        redirect_to show_user_registration_path params.except([:controller, :action])
      end
    end

    def terms_accepted?
      %w(payment_terms printed_terms).map { |t| params["accept_#{t}"] == '1' }.all?
    end

    def cprs_valid?
      ['cpr1', 'cpr2'].all? { |p| params[p] && params[p].match(/^\d{6}-?\d{4}$/) }
    end

    def cprs_match?
      params['cpr1'] == params['cpr2']
    end

    # Devise doen't return in create function, so can't add code after
    # a super call.
    # So this seems to be the best place to link users together.
    def after_sign_in_path_for(resource)
      if resource.user.nil?
        # Map to the current user in user scope
        logger.info "Warden info: #{env['warden']}"
        user = env['warden'].user(:user)
        if user.nil?
          # The user logged into the session has expired
          # We need to relogin to complete the process.
          # TODO: Make sure proper message is displayed.
          logger.error "User is nil"
          throw(:warden)
        end

        resource.user = user
        resource.save!

        user.aleph_borrower
      else
        logger.info "DkNemIdUser #{resource.inspect} already assigned to user #{resource.user.inspect}."
        return nemid_already_assigned_path
      end
      show_user_registration_path
    end

    def already_assigned
      redirect_to show_user_registration_path unless current_user &&
                                                     current_dk_nemid_user &&
                                                     current_dk_nemid_user.user.id != current_user.id
      @user = current_user
      @other_user = current_dk_nemid_user.user
    end

    def destroy
      super
      flash.clear
    end

    def auth_options
      super.merge(:recall => 'users/registrations#show')
    end
  end
end
