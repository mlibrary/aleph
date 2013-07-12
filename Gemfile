source 'https://rubygems.org'

gem 'rails', '~> 3.2'
gem 'jquery-rails', '~> 2.3.0'
gem 'activeadmin'
gem 'devise'
gem 'devise_cas_authenticatable'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-oauth2'
gem 'devise_cas_server_extension', :git =>
       'https://github.com/dtulibrary/devise_cas_server_extension'
gem 'capistrano', '~> 2.15'
gem 'bootstrap-sass'
gem 'rubycas-client'
gem 'httparty'
gem 'nokogiri'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'findit_font', :git => 'git://github.com/dtulibrary/findit_font.git'
  gem 'turbo-sprockets-rails3'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'debugger'
  gem 'brakeman'
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
  gem 'rails_best_practices'
end

group :production do
  gem 'pg'
end


