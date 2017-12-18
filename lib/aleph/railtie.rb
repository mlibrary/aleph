require 'rails'
module Aleph
  class Railtie < Rails::Railtie
    initializer 'aleph.initialize' do
      Aleph.load_config(Rails.root.join('config', 'aleph.yml'))
    end
  end
end