require 'simplecov'
require 'simplecov-html'
require 'simplecov-rcov'

class SimpleCov::Formatter::MergedFormatter
  def format(result)
     SimpleCov::Formatter::HTMLFormatter.new.format(result)
     SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end
SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
SimpleCov.start 'rails'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'mocha'
require 'factory_girl_rails'
require 'webmock/rspec'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.use_transactional_fixtures = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.infer_base_class_for_anonymous_controllers = false
  config.mock_with :mocha

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Dir[Rails.root.join("spec/helpers/*.rb")].each {|f| require f}

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
  'provider' => 'facebook',
  'uid' => '123545',
  'info' => {
    'email' => 'facebook@test.domain',
    'first_name' => 'Test',
    'last_name' => 'User',
    'user_type' => 'testing',
  }
})
OmniAuth.config.mock_auth[:facebook_update] = OmniAuth::AuthHash.new({
  'provider' => 'facebook',
  'uid' => '123545',
  'info' => {
    'email' => 'updated@test.domain',
    'first_name' => 'Test2',
    'last_name' => 'User2',
    'user_type' => 'testing',
  }
})
OmniAuth.config.mock_auth[:linkedin] = OmniAuth::AuthHash.new({
  'provider' => 'linkedin',
  'uid' => '123556',
  'info' => {
    'email' => 'linkedin@test.domain',
    'first_name' => 'Test',
    'last_name' => 'User',
    'user_type' => 'testing',
  }
})
OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
  'provider' => 'google_oauth2',
  'uid' => '123567',
  'info' => {
    'email' => 'google@test.domain',
    'first_name' => 'Test',
    'last_name' => 'User',
    'user_type' => 'testing',
  }
})
