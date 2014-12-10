module Users
  #
  class RegistrationsController < Devise::RegistrationsController
    def create
      super
      session[:pending_after_sign_in_path] = params[:service]
      return nil unless params[:address]

      address = Address.create(params[:address])
      address.line1 = resource.first_name
      resource.address = address
      resource.save!
    end

    def show
      return if redirect_to_ill_user
      authenticate_scope!
      return if pending_redirect_to_printed_collection

      expires_now
    rescue ArgumentError => e
      flash[:error] = 'Nemid validation failed. Please try again later. '\
                      'If the error persists, please contact DTU Library' if e.message.include?(':warden')
      redirect_to show_user_registration_path
    end

    def redirect_to_ill_user
      return false unless request.env['warden'].user(:ill_user)

      sign_out(:user) if request.env['warden'].user(:user)
      redirect_to show_ill_user_registration_path
    end

    def pending_redirect_to_printed_collection
      return false unless session[:pending_after_sign_in_path] &&
                          resource.may_lend_printed?

      logger.info 'Pending after_sign_in_path found in session and user may '\
                  'lend printed materials. Redirecting to pending path.'
      resource.aleph_borrower
      redirect_to session.delete(:pending_after_sign_in_path)
    end

    def dedicated
    end

    def update_resource(resource, account_update_params)
      if account_update_params[:address]
        resource.address.update_attributes(account_update_params[:address])
        result = resource.address.save
        account_update_params.delete(:address)
      end
      super && result
    end

    def after_inactive_sign_up_path_for(_)
      user_wait_mail_path
    end
  end
end
