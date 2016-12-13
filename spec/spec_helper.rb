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
require 'capybara/poltergeist'
require 'capybara/mechanize'

RSpec.configure do |config|
  config.before(:suite) do
    require File.dirname(__FILE__) + '/../db/seeds.rb'
  end

  config.formatter = :documentation
  config.color_enabled = true

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

  config.mock_framework = :rspec

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Dir[Rails.root.join("spec/helpers/*.rb")].each {|f| require f}

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {:debug => false, :phantomjs => Phantomjs.path})
end
Capybara.javascript_driver = :poltergeist


# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

