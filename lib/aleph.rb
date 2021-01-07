# frozen_string_literal: true

module Aleph
  class << self
    attr_accessor :aleph_x_url, :aleph_rest_url, :bib_library,
                  :adm_library, :bor_prefix, :bor_type_id, :z303_defaults,
                  :z304_defaults, :z305_defaults, :item_mapping, :z308_defaults,
                  :create_aleph_borrowers, :test_mode, :services,
                  :status_intent_map

    def load_config(config_file)
      yaml_config = YAML.load(ERB.new(File.read(config_file)).result)
      self.aleph_x_url = yaml_config['aleph_x_url']
      self.bib_library = yaml_config['bib_library']
      self.adm_library = yaml_config['adm_library']
      self.services    = yaml_config['services']
      self.status_intent_map = yaml_config['status']
      self
    end

    def intent(status)
      status_intent_map.each do |map|
        return map['intent'] if status.start_with?(map['start_with'])
      end
      nil
    end

    def icon(status)
      status_intent_map.each do |map|
        return map['icon'] if status.start_with?(map['start_with'])
      end
      nil
    end

    def setup
      yield self
    end

    def config
      self
    end
  end
end

require 'aleph/error'
require 'aleph/base'
require 'aleph/connection'
require 'aleph/borrower'
require 'aleph/version'

require 'aleph/railtie' if defined?(Rails)
