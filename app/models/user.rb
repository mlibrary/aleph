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
  belongs_to :user_sub_type
  has_many :identities, :dependent => :destroy
  has_many :dk_nemid_users, :dependent => :destroy
  belongs_to :address, :dependent => :destroy

  accepts_nested_attributes_for :address

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :user_type_id, :authenticator, :first_name, :last_name, :user_sub_type_id,
    :librarycard, :address_attributes
  attr_reader :direct_login

  # Devise does validation for email and password
  validates :user_type, :presence => true
  validates :first_name, :presence => true, :if => "require_first_name?"
  validates :last_name, :presence => true, :if => "require_last_name?"
  validates_each :email do |record, attr, value|
    if (!record.dtu_affiliate?) && value =~ /[@.]dtu\.dk$/
      record.errors.add(attr, I18n.t('riyosha.user.dtu_email'))
    end
  end

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
    return nil if info['reason'] == 'lookup_failed'
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

  def library?
    self.user_type.code == 'library'
  end

  def dtu_affiliate?
    case self.user_type.code
    when "dtu_empl", "student"
      true
    else
      false
    end
  end

  # May this user lend printed material (through ALEPH)
  # Any DTU employee or student may always lend printed material
  # Private users need to login through Nemid, and accept our terms.
  def may_lend_printed?
    expand
    if @cpr.blank?
      return false
    end
    if user_type.code == 'dtu_empl' || user_type.code == 'student'
      return true
    end
    if !nemid_needed?
      return true
    end
    false
  end

  def nemid_needed?
    if user_type.code == 'dtu_empl' || user_type.code == 'student'
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

  def aleph_borrower
    if show_feature?(:aleph)
      begin
        @aleph ||= Aleph::Borrower.new(self) if may_lend_printed?
      rescue
        logger.error "Could not update Aleph for user #{self.inspect}"
      end
    end
  end
  
  def aleph_bor_status_type
    expand
    return [aleph_bor_status, aleph_bor_type]
  end

  def birth_day
    expand 
    return '' if @cpr.nil?
    day = @cpr[0, 2].to_i
    month = @cpr[2, 2].to_i
    year = @cpr[4, 2].to_i
    century = @cpr[6, 1].to_i
    if century <= 3
      year += 1900
    elsif century == 4 || century == 9
      if year <= 36
        year += 2000
      else
        year += 1900
      end
    else
      if year <= 57
        year += 2000
      else
        year += 1800
      end
    end
    format("%04d%02d%02d", year, month, day)
  end

  def gender
    expand
    return '' if @cpr.nil?
    ((@cpr[9, 1].to_i % 2) == 1) ? 'M' : 'F'
  end

  def aleph_ids
    expand
    # Create additional ids
    ids = Array.new

    ids << { 'type' => '03',
      'id' => "DTU#{@cpr}",
      'pin'  => nil,
    } if self.user_type.code == 'dtu_empl'

    ids << { 'type' => '03',
      'id' => "STUD#{@cpr}",
      'pin'  => nil,
    } if self.user_type.code == 'student'

    ids << { 'type' => '03',
      'id' => @expanded[:dtu]['initials'].upcase,
      'pin'  => nil,
    } if @expanded[:dtu] && !@expanded[:dtu]['initials'].blank?

    ids << { 'type' => '03',
      'id' => "CWIS#{@expanded[:dtu]['matrikel_id']}",
      'pin'  => nil,
    } if @expanded[:dtu] && !@expanded[:dtu]['matrikel_id'].blank?

    ids << { 'type' => '03',
      'id' => @cpr,
      'pin'  => nil,
    } if self.user_type.code == 'private'

    ids << { 'type' => '01',
      'id' => librarycard,
      'pin' => nil,
    } unless librarycard.blank?

    ids
  end

  def address_lines
    expand
    @expanded[:address] ? @expanded[:address].to_a : Array.new
  end

  private

  def do_expand_user
    @expanded = as_json
    @expanded[:user_type] = user_type.code
    if dtu_affiliate?
      ident = Identity.find_by_user_id_and_provider(id, 'dtu')
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
    @cpr = @dtubase.cpr
  end

  def expand_local
    @expanded[:address] = address unless address.nil?
    @cpr = local_cpr
  end

  def local_cpr
    dk_nemid_users.each do |nemid|
      return nemid.cpr unless nemid.cpr.blank?
    end
    nil
  end

  def aleph_bor_status
    (user_sub_type.nil? ? nil : user_sub_type.aleph_bor_status) ||
      user_type.aleph_bor_status
  end

  def aleph_bor_type
    (user_sub_type.nil? ? nil : user_sub_type.aleph_bor_type) ||
      user_type.aleph_bor_type
  end

  def require_first_name?
    !anon?
  end

  def require_last_name?
    !(anon? || library?)
  end

end
