source 'https://rubygems.org'

gem 'rails'
gem 'jquery-rails'
gem 'activeadmin'
gem 'devise'
gem 'devise_cas_authenticatable'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'debugger'
end

group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-html', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'mocha', :require => false
  gem 'factory_girl_rails'
end

group :development do
  gem 'rails_best_practices'
end

group :production do
  gem 'pg'
end


