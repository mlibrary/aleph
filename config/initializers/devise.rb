require "omniauth-facebook"
require "omniauth-linkedin-oauth2"
require "omniauth-google-oauth2"
require "devise_cas_server_extension"
require "devise_dk_nemid"

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  # ==> Mailer Configuration
  config.mailer_sender = "local@localhost"

  # ==> ORM configuration
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.params_authenticatable = true
  config.http_authenticatable = false
  config.paranoid = true
  config.skip_session_storage = [:http_auth]

  # ==> :database_authenticatable
  config.stretches = Rails.env.test? ? 1 : 10
  config.pepper = Rails.application.config.devise[:pepper]
  config.secret_key = Rails.application.config.devise[:secret_key] if config.respond_to? :secret_key

  # ==> :confirmable
  config.reconfirmable = true
  config.confirmation_keys = [ :email ]

  # ==> :rememberable
  config.remember_for = 6.months
  config.extend_remember_period = true

  # ==> :timeoutable
  config.timeout_in = 30.minutes
  config.expire_auth_token_on_timeout = true

  # ==> :lockable
  config.lock_strategy = :failed_attempts
  config.unlock_keys = [ :email ]
  config.unlock_strategy = :both
  config.maximum_attempts = 10
  config.unlock_in = 1.hour

  # ==> :recoverable
  config.reset_password_keys = [ :email ]
  config.reset_password_within = 6.hours

  # ==> scopes
  config.default_scope = :user
  config.sign_out_all_scopes = false
  config.sign_out_via = :get

  # ==> OmniAuth
  config.omniauth :facebook,      Rails.application.config.omniauth[:facebook][:id], 
                                  Rails.application.config.omniauth[:facebook][:secret]
  config.omniauth :linkedin,      Rails.application.config.omniauth[:linkedin][:id], 
                                  Rails.application.config.omniauth[:linkedin][:secret]
  config.omniauth :google_oauth2, Rails.application.config.omniauth[:google_oauth2][:id], 
                                  Rails.application.config.omniauth[:google_oauth2][:secret], 
                                  {access_type: 'online', approval_prompt: ''}

  # ==> CAS
  config.cas_base_url = Rails.application.config.cas[:url]
  config.cas_create_user = false
  config.cas_server_maximum_session_lifetime = 120
  config.cas_server_maximum_unused_service_ticket_lifetime = 120
  config.cas_server_maximum_session_lifetime = 86400

  # ==> NemID
  if config.respond_to? :dk_nemid_certificate_password
    config.dk_nemid_certificate_password = Rails.application.config.nemid[:certificate_password]
    config.dk_nemid_certificate_path = Rails.application.config.nemid[:certificate_path]
    config.dk_nemid_allowed = Rails.application.config.nemid[:allowed]
    config.dk_nemid_cpr_service = Rails.application.config.nemid[:cpr_service]
    config.dk_nemid_cpr_pid_spid = Rails.application.config.nemid[:cpr_pid_spid]
    config.dk_nemid_proxy = Rails.application.config.nemid[:proxy]
  end

end
