class UserSubType < ActiveRecord::Base
  attr_accessible :aleph_bor_status, :aleph_bor_type, :code, :user_type_id

  belongs_to :user_type

  validates :code, :presence => true
  validates :user_type, :presence => true
  validates :aleph_bor_status, :numericality => { :only_integer => true },
    :allow_blank => true
  validates :aleph_bor_type, :numericality => { :only_integer => true },
    :allow_blank => true
  validates_uniqueness_of :code, :scope => :user_type_id

  def name
    I18n.t(code, :scope => 'riyosha.code.user_sub_type.' + user_type.code)
  end

end
