require 'aleph'

Aleph.setup do |config|
  config.aleph_x_url = Rails.application.config.aleph[:url]
  config.bor_prefix = Rails.application.config.aleph[:prefix]
  config.create_aleph_borrowers = Rails.application.config.aleph[:create_users]
  if Rails.application.config.aleph[:stub] 
    config.test_mode = true
  end
end