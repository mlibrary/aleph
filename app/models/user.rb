class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :cas_server,
         :lockable, :omniauthable, :omniauth_providers => [:facebook]

  belongs_to :user_type
  has_many :identities, :dependent => :destroy

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :user_type_id

  validates :email, :presence => true, :uniqueness => true
  validates :password, :presence => true
  validates :password_confirmation, :presence => true
  validates :user_type, :presence => true

  def self.create_from_omniauth(auth, type_id)
    user = User.new
    user.email = auth.info.email
    user.password = Devise.friendly_token[0,20]
    user.user_type_id = type_id
    user.password_confirmation = user.password
    user.confirm!
    user.save!
    user
  end

end
