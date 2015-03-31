require 'rubycas-client'
require 'dtubase'

class Users::SessionsController < Devise::SessionsController
  include Devise::CasServer::SessionsControllerBehaviour

  before_filter :dispatch_to_ill_user, :only => [:new, :validate, :proxyValidate, :serviceValidate]

  def new
    session[:template] = params[:template] if params[:template]
    session[:template] ||= 'local_user'
    if (user = ticket_valid(params['ticket']))
      user.aleph_borrower
      sign_in_and_redirect user, :event => :authentication
    elsif params[:only] == 'dtu'
      redirect_to dtu_login_url
    else
      @login_template = session[:template]
      super
    end
  end

  def after_sign_in_path_for(resource)
    params[:resource] = resource # this is an ugly hack
    super
  end

  def create_service_url(tgt)
    resource = params.delete(:resource)
    resource.aleph_borrower
    if authenticating_aleph? && !resource.may_lend_printed? 
      logger.info "Authentication request is from Aleph and user may not lend printed materials. Storing after_sign_in_path in session."
      session[:pending_after_sign_in_path] = super
      show_user_registration_path
    else 
      super
    end
  end
  
  def dtu_login_url
    cas_client.add_service_to_login_url url_for(:only_path => false)
  end

  def cas_client
    @@cas_client ||= CASClient::Client.new(
      :cas_base_url => Rails.application.config.cas[:base_url],
      :validate_url => "#{Rails.application.config.cas[:base_url]}/serviceValidate")
  end

  def ticket_valid(ticket)
    return false if ticket.nil? || ticket.blank?

    # Use Ruby Cas Client for validation
    st = CASClient::ServiceTicket.new(ticket, url_for(:only_path => false))
    cas_client.validate_service_ticket(st)
    if st.is_valid?
      info, adr = begin
                    DtuBase.lookup(:username => st.user)
                  rescue => e
                    logger.error(e.message)
                    flash[:error] = I18n.t('riyosha.error.dtubase')
                    [nil, nil]
                  end

      return nil unless info

      user = User.create_from_dtubase_info(info)
      flash[:error] = I18n.t('riyosha.error.dtubase') if user.nil?
      user
    else
      nil
    end
  end

  def destroy
    sign_out_all_scopes
    super
    flash.clear
  end

  def dispatch_to_ill_user
    if request.env['warden'].user(:ill_user)
      logger.info 'Ill User already logged in. Dispatching to :ill_user scope for #{params}'
      sign_out(:user) if request.env['warden'].user(:user)
      redirect_to params.merge(:controller => 'ill_users/sessions') and return
    end
  end

  helper_method :authenticating_aleph?
  def authenticating_aleph?
    aleph_url? session[:cas_server_service]
  end

  helper_method :aleph_url?
  def aleph_url? url
    aleph_urls = [Rails.application.config.aleph[:url], Rails.application.config.aleph[:alternate_urls]].flatten
    url && aleph_urls.any?{|aleph_url| url.start_with?(aleph_url)}
  end
  
end
