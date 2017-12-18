module Aleph

  class << self
    attr_accessor :aleph_x_url, :aleph_rest_url, :bib_library,
      :adm_library, :bor_prefix, :bor_type_id, :z303_defaults,
      :z304_defaults, :z305_defaults, :item_mapping, :z308_defaults,
      :create_aleph_borrowers, :test_mode

    def load_config(config_file)
      yaml_config = YAML.load_file(config_file)
      self.aleph_x_url = yaml_config['aleph_x_url']
      self.bib_library = yaml_config['bib_library']
      self.adm_library = yaml_config['adm_library']
      self
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

if defined?(Rails)
  require 'aleph/railtie'
end
