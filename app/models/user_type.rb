class UserType < ActiveRecord::Base
  attr_accessible :code, :aleph_bor_status, :aleph_bor_type

  validates :code, presence: true, :uniqueness => true
  validates :aleph_bor_status, :numericality => { :only_integer => true }
  validates :aleph_bor_type, :numericality => { :only_integer => true }

  has_many :users, :dependent => :restrict
  has_many :user_sub_types, :dependent => :restrict

  def name
    I18n.t code, :scope => 'riyosha.code.user_type'
  end

end
