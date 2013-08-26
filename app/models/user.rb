require 'httparty'
require 'nokogiri'
require 'dtubase'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :cas_server, :lockable, :omniauthable,
         :omniauth_providers => [:facebook, :linkedin, :google_oauth2]

  belongs_to :user_type
  has_many :identities, :dependent => :destroy

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :user_type_id, :authenticator, :first_name, :last_name
  attr_reader :direct_login

  validates :email, :presence => true, :uniqueness => true
#  validates :password, :presence => true
#  validates :password_confirmation, :presence => true
  validates :user_type, :presence => true
  validates :first_name, :presence => true, :if => "!anon?"
  validates :last_name, :presence => true, :if => "!anon?"

  def self.login_from_omniauth(auth)
    identity = Identity.find_with_omniauth(auth)
    type_id = UserType.where(:code => (auth.info.user_type || 'private')).first.id

    if identity.nil?
      user = self.where(:email => auth.info.email, :user_type_id =>
        type_id).first
      user = self.create_from_omniauth(auth, type_id) unless user
      return nil if user.nil?

      identity = Identity.create(:uid => auth.uid, :provider => auth.provider,
        :user_id => user.id)
      identity.save!
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
    user.save!
    user
  end

  def update_from_omniauth(auth)
    logger.info "First name #{auth.info.first_name}"
    logger.info "Last name #{auth.info.first_name}"
    self.email = auth.info.email
    self.first_name = auth.info.first_name
    self.last_name = auth.info.last_name
  end

  def expand
    @expanded = as_json
    @expanded[:user_type] = user_type.code
    ident = Identity.find_by_user_id_and_provider(id, 'dtu')
    if ident
      expand_dtu ident.uid
    end
    @expanded
  end

  def expand_dtu(uid)
    @expanded[:dtu] = DtuBase.lookup(:cwis => uid)
  end

  def anon?
    self.user_type.code == 'anon'
  end

end
