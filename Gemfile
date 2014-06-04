source 'https://rubygems.org'

gem 'rails', '~> 3.2.18'
gem 'jquery-rails', '~> 2.3.0'
gem 'activeadmin'
gem 'sru'

gem 'devise'
gem 'devise_cas_authenticatable'
#gem 'devise_cas_server_extension', :git => 'https://github.com/dtulibrary/devise_cas_server_extension'
gem 'devise_cas_server_extension', :path => '../devise_cas_server_extension'
gem 'devise_dk_nemid', :git => 'https://github.com/dtulibrary/devise_dk_nemid'
gem 'xmldsig', :git => 'https://github.com/dtulibrary/xmldsig'

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-oauth2'

gem 'capistrano', '~> 2.15'
gem 'bootstrap-sass', '~> 2.3.0'
gem 'rubycas-client'
gem 'httparty'
gem 'nokogiri'
gem 'feature_flipper', '~> 1.3'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'findit_font', :git => 'git://github.com/dtulibrary/findit_font.git'
  gem 'turbo-sprockets-rails3'
  gem 'jquery-cookie-rails'
end

group :development, :test do
  gem 'pry-rails'
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  gem 'capybara-mechanize'
  gem 'debugger'
  gem 'brakeman'
  gem 'quiet_assets'
end

group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-html', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'mocha', :require => false
  gem 'factory_girl_rails'
  gem 'webmock'
end

group :development do
  gem 'quiet_assets'
  gem 'rails_best_practices'
end

group :production do
  gem 'pg'
end


