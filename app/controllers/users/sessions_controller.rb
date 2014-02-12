require 'rubycas-client'
require 'dtubase'

class Users::SessionsController < Devise::SessionsController

  def new
    session[:template] = params[:template] if params[:template]
    session[:template] ||= 'local_user'
    if (user = ticket_valid(params['ticket']))
      sign_in_and_redirect user, :event => :authentication
    elsif params[:only] == 'dtu'
      redirect_to dtu_login_url
    else
      @login_template = session[:template]
      super
    end
  end

  def dtu_login_url
    cas_client.add_service_to_login_url url_for(:only_path => false)
  end

  def cas_client
    @@cas_client ||= CASClient::Client.new(
      :cas_base_url => Rails.application.config.dtu_auth_url,
      :validate_url => "#{Rails.application.config.dtu_auth_url}/serviceValidate")
  end

  def ticket_valid(ticket)
    return false if ticket.nil? || ticket.blank?

    # Use Ruby Cas Client for validation
    st = CASClient::ServiceTicket.new(ticket, url_for(:only_path => false))
    cas_client.validate_service_ticket(st)
    if st.is_valid?
      logger.info "Service Ticket is valid for #{st.user}"
      if session[:fake_login]
        info, adr = DtuBase.lookup(:cwis => session[:fake_login])
      else
        info, adr = DtuBase.lookup(:username => st.user)
      end
      return nil if info.nil?
      User.create_from_dtubase_info(info)
    else
      nil
    end
  end

  def destroy
    super
    flash.clear
  end

end
