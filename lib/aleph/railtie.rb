# frozen_string_literal: true

require 'rails'
module Aleph
  class Railtie < Rails::Railtie
    initializer 'aleph.initialize' do
      file = Rails.root.join('config', 'aleph.yml')
      Aleph.load_config(file) if File.exist?(file)
    end
  end
end
