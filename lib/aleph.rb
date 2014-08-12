module Aleph

  # Url for Aleph X server
  mattr_accessor :aleph_x_url
  @@aleph_x_url = nil

  # Url for Aleph restful server
  mattr_accessor :aleph_rest_url
  @@aleph_rest_url = nil

  # Default bibliographic library
  mattr_accessor :bib_library
  @@bib_library = "DTV01"

  # Default administrative library
  mattr_accessor :adm_library
  @@adm_library = "DTV50"

  # Borrower prefix used to create unique identifiers.
  mattr_accessor :bor_prefix
  @@bor_prefix = "RUBY"

  # Borrower type id create (Z308-TYPE-ID)
  mattr_accessor :bor_type_id
  @@bor_type_id = "02"

  mattr_accessor :z303_defaults
  @@z303_defaults = {
    'z303-alpha' => 'L',
    'z303-con-lng' => 'ENG',
    'z303-ill-library' => '820060',
    'z303-ill-total-limit' => '9999',
    'z303-ill-active-limit' => '9999',
    'z303-proxy-id-type' => '00',
    'z303-send-all-letters' => 'Y',
    'z303-title-req-limit' => '0000',
    'z303-profile-id' => 'DTV_ENG',
    'z303-plain-html' => 'P',
    'z303-home-library' => 'DTV',
    'z303-plif-modification' => '',
    'z303-want-sms' => 'N',
  }

  mattr_accessor :z304_defaults
  @@z304_defaults = {
    'z304-date-to' => '20991231',
  }

  mattr_accessor :z305_defaults
  @@z305_defaults = {}

  mattr_accessor :z308_defaults
  @@z308_defaults = {
    'z308-status' => 'AC',
    'z308-encryption' => 'N',
    'z308-verification-type' => '00',
  }

  # Default will be unavailable if no mapping present.
  mattr_accessor :item_mapping
  @@item_mapping = {
    '01' => 'available',
    '02' => 'available',
    '03' => 'available',
    '04' => 'restricted',
    '05' => 'restricted',
    '08' => 'restricted', 
    '09' => 'restricted',
    '20' => 'available',
    '61' => 'limited',
    '62' => 'limited',
    '63' => 'limited',
    '64' => 'limited',
    '65' => 'request',
    '66' => 'request',
  }

  # Should we create users that doesn't exists.
  mattr_accessor :create_aleph_borrowers
  @@create_aleph_borrowers = false

  mattr_accessor :test_mode
  @@test_mode = false

  def self.setup
    yield self
  end

  def self.config
    self
  end
end

require 'aleph/error.rb'
require 'aleph/base.rb'
require 'aleph/connection.rb'
require 'aleph/borrower.rb'

