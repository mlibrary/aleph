load File.dirname(__FILE__) + '/production.rb'

Riyosha::Application.configure do
  # Force all access to the app over SSL, use Strict-Transport-Security, and
  # use secure cookies.
  config.force_ssl = false
end
