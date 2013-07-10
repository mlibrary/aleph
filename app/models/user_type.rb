class UserType < ActiveRecord::Base
  attr_accessible :code

  validates :code, presence: true, :uniqueness => true

  has_many :users, :dependent => :restrict

  def name
    I18n.t code, :scope => 'riyosha.code.user_type'
  end

end
