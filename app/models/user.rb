require 'httparty'
require 'nokogiri'
require 'dtubase'
require 'devise'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :cas_server, :lockable, :omniauthable,
         :omniauth_providers => [:facebook, :linkedin, :google_oauth2],
         :authentication_keys => [:email]

  belongs_to :user_type
  has_many :identities, :dependent => :destroy
  has_many :dk_nemid_users, :dependent => :destroy
  belongs_to :address, :dependent => :destroy

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :user_type_id, :authenticator, :first_name, :last_name,
    :accept_payment_terms, :accept_printed_terms
  attr_reader :direct_login

  # Devise does validation for email and password
  validates :user_type, :presence => true
  validates :first_name, :presence => true, :unless => "anon?"
  validates :last_name, :presence => true, :unless => "anon?"

  def self.login_from_omniauth(auth)
    identity = Identity.find_with_omniauth(auth)
    type_id = UserType.where(:code => (auth.info.user_type ||
      'private')).first.id

    if identity.nil?
      user = self.where(:email => auth.info.email.downcase, :user_type_id =>
        type_id).first unless auth.info.email.blank?
      user = self.create_from_omniauth(auth, type_id) unless user
      return nil if user.nil?

      identity = Identity.create!(:uid => auth.uid, :provider => auth.provider,
        :user_id => user.id)
    else
      user = identity.user
      user.update_from_omniauth(auth)
      user.user_type_id = type_id
    end
    user.authenticator = auth.provider
    user.save!
    user
  end

  def self.create_from_omniauth(auth, type_id)
    user = User.new
    user.update_from_omniauth(auth)
    user.user_type_id = type_id
    user.password = Devise.friendly_token[0,20]
    user.password_confirmation = user.password
    user.confirm!
    user
  end

  def update_from_omniauth(auth)
    skip_reconfirmation!
    self.email = auth.info.email.downcase
    self.first_name = auth.info.first_name
    self.last_name = auth.info.last_name
    confirm!
  end

  def self.create_from_dtubase_info(info)
    self.login_from_omniauth(OmniAuth::AuthHash.new(
      'provider' => 'dtu',
      'uid' => info['matrikel_id'],
      'info' => {
        'email' => info['email'],
        'first_name' => info['firstname'],
        'last_name' => info['lastname'],
        'user_type' => info['user_type'],
      }
    ))
  end

  def expand
    @expanded ||= do_expand_user
  end

  def anon?
    self.user_type.code == 'anon'
  end

  def dtu_affiliate?
    case self.user_type.code
    when "dtu_employee", "student"
      true
    else
      false
    end
  end

  # May this user lend printed material (through ALEPH)
  # Any DTU employee or student may always lend printed material
  # Private users need to login through Nemid, and accept our terms.
  def may_lend_printed?
    @may_lend_printed ||= set_may_lend_printed
  end

  def requirements_for_lending_printed
    if dtu_affiliate?
      return nil
    end
    nemid_needed = nemid_needed?
    # If no part of the process completed, assume the user hasn't begun
    # the process and return an empty list of requirements.
    if nemid_needed && !accept_payment_terms && !accept_printed_terms
      return nil
    end
    list = Array.new
    if dk_nemid_users.nil?
      list << I18n.t('riyosha.edit.need.nemid')
    elsif nemid_needed
      list << I18n.t('riyosha.edit.need.cpr')
    end
    if !accept_payment_terms
      list << I18n.t('riyosha.edit.need.payment_terms')
    end
    if !accept_printed_terms
      list << I18n.t('riyosha.edit.need.printed_terms')
    end
  end

  def nemid_needed?
    if user_type.code == 'dtu_employee' || user_type.code == 'student'
      return false
    end
    local_cpr.nil? ? true : false;
  end

  def address_from_cpr
    cpr = local_cpr
    return false if cpr.nil?
    new_address = CprStam.lookup(cpr)
    if address.nil?
      return false unless new_address.save
      self.address = new_address
      return false unless save
    else
      # Check for update
      update = false
      new_address.each do |key, new_value|
        curr_value = new_address.send(key)
        if curr_value != new_value
          user.address.send("#{key}=", new_value)
          update = true
        end
      end
      if update
        return false unless address.save
      end
    end
    true
  end

  private

  def do_expand_user
    @expanded = as_json
    @expanded[:user_type] = user_type.code
    ident = Identity.find_by_user_id_and_provider(id, 'dtu')
    if ident
      expand_dtu ident.uid
    else
      expand_local
    end
    @expanded
  end

  def expand_dtu(uid)
    @dtubase ||= DtuBase.new
    @dtubase.lookup_single(:cwis => uid)
    @expanded[:dtu] = @dtubase.to_hash
    @expanded[:address] = @dtubase.address
    #@cpr = @dtubase.cpr
  end

  def expand_local
    @expanded[:address] = address.to_hash if address
    @cpr = local_cpr
  end

  def set_may_lend_printed
    if user_type.code == 'dtu_employee' || user_type.code == 'student'
      return true
    end
    if !nemid_needed? && accept_payment_terms && accept_printed_terms
      return true
    end
    false
  end

  def local_cpr
    dk_nemid_users.each do |nemid|
      return nemid.cpr unless nemid.cpr.blank?
    end
    nil
  end

end
