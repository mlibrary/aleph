class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  belongs_to :user_type

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :user_type_id

  validates :email, :presence => true, :uniqueness => true
  validates :password, :presence => true
  validates :password_confirmation, :presence => true
  validates :user_type, :presence => true
end
