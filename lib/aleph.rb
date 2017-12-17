module Aleph
  class << self
    attr_accessor :aleph_x_url, :aleph_rest_url, :bib_library,
      :adm_library, :bor_prefix, :bor_type_id, :z303_defaults,
      :z304_defaults, :z305_defaults, :item_mapping, :z308_defaults,
      :create_aleph_borrowers, :test_mode
  end

  def self.setup
    yield self
  end

  def self.config
    self
  end
end

require 'aleph/error'
require 'aleph/base'
require 'aleph/connection'
require 'aleph/borrower'
require 'aleph/version'
