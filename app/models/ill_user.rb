class IllUser < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable, :authentication_keys => [:library_id]

  belongs_to :address, :dependent => :destroy
  has_many :identities, :dependent => :destroy
  belongs_to :user_type
  belongs_to :user_sub_type

  accepts_nested_attributes_for :address

  attr_accesible :library_id, :email, :password, :password_confirmation, :remember_me, :user_type_id, :user_sub_type_id

  validates :user_type, :presence => true
  validates :library_id, :presence => true
  validates :email, :presence => true
  
end
