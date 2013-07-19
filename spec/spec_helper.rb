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
  config.filter_run :focus
  config.use_transactional_fixtures = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.infer_base_class_for_anonymous_controllers = false
  config.mock_with :mocha
end
Riyosha::Application.config.secret_token = '2a9bd08baa64aa149bbbbcc3f13'\
  '298ac013192f48f0a1839e0687ffa3c17807d4b451637e816fd55b6817a1ffa46d04e'\
  '016f0c6bd7c1275373fcf3139dba307c'

Dir[Rails.root.join("spec/helpers/*.rb")].each {|f| require f}


OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
  'provider' => 'facebook',
  'uid' => '123545',
  'info' => {
    'email' => 'facebook@test.domain'
  }
})
