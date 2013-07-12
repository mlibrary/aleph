require 'rubycas-client'
require 'dtubase'

class Users::SessionsController < Devise::SessionsController
  def new
    if (params['clear_checked'])
      session[:checked_in_dtu_base] = false
      session[:fake_login] = nil
    end
    session[:fake_login] = params['fake_login'] if !Rails.env.production?

    # Set default template
    @login_template = session[:template] || 'local_user'
    if (user = ticket_valid(params['ticket']))
      logger.info "Redirect sign_in"
      sign_in_and_redirect user, :event => :authentication
    elsif send_to_dtu
      redirect_to dtu_login_url
    elsif !session[:checked_in_dtu_base]
      session[:checked_in_dtu_base] = true
      logger.info "Redirect to #{dtu_login_url}"
      redirect_to dtu_login_url+"&gateway=true"
    else
      case params['template']
      when 'dtu_user'
        @login_template = params['template']
      end
      session[:template] = @login_template
      super
    end
  end

  def dtu_login_url
    cas_client.add_service_to_login_url url_for(:only_path => false) 
  end

  def send_to_dtu
    params['only'] == 'dtu'
  end

  def ticket_valid(ticket)
    return false if ticket.nil? || ticket.blank?

    # Use Ruby Cas Client for validation
    @login_template = 'dtu_user'
    st = CASClient::ServiceTicket.new(ticket, url_for(:only_path => false))
    cas_client.validate_service_ticket(st)
    if st.is_valid?
      logger.info "Service Ticket is valid for #{st.user}"
      if session[:fake_login]
        info = DtuBase.lookup(:cwis => session[:fake_login])
      else
        info = DtuBase.lookup(:username => st.user)
      end
      return nil if info.nil?
      logger.info "DtuBase info #{info.inspect}"
      # Do we know this user already?
      identity = Identity.find_by_provider_and_uid('dtu', info['matrikel_id'])
      type_id = UserType.find_by_code(info['user_type']).id
      if identity.nil?
        user = User.where(:email => info['email'], :user_type_id => type_id).first
        user = User.create_from_dtu(info, type_id) unless user
        return nil if user.nil?
        identity = Identity.create(:uid => info['matrikel_id'],
          :provider => 'dtu', user_id: user.id)
        identity.save!
      else
        # TODO: Check for duplicate email!
        identity.user.email = info['email']
        identity.user.user_type_id = type_id
      end
      identity.user.authenticator = 'dtu'
      identity.user.save!
      identity.user
    else
      nil 
    end
  end

  def cas_client
    @@cas_client ||= CASClient::Client.new(:cas_base_url =>
      Rails.application.config.dtu_auth_url)
  end

end
