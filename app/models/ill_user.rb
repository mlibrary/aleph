class IllUser < ActiveRecord::Base
  include Concerns::AlephUser

  devise :database_authenticatable, :cas_server, :recoverable, :rememberable, :trackable, :lockable, 
         :authentication_keys => [:library_id], 
         :reset_password_keys => [:email, :library_id],
         :unlock_keys => [:email, :library_id]

  belongs_to :address, :dependent => :destroy
  belongs_to :user_type
  belongs_to :user_sub_type

  accepts_nested_attributes_for :address

  attr_accessible :library_id, :name, :email, :password, :password_confirmation, :remember_me, :user_type_id, :user_sub_type_id

  validates :user_type,     :presence => true
  validates :user_sub_type, :presence => true
  validates :library_id,    :presence => true, :uniqueness => true
  validates :email,         :presence => true

  def self.create_or_update_from_vip_base(branch)
    if branch.deleted?
      #delete_from_vip_base(branch)
    else
      logger.warn "Email is blank for library id #{branch.library_id}" and return if branch.email.blank?
      logger.warn "Library type is blank for library id #{branch.type}" and return if branch.type.blank?

      user = IllUser.find_or_initialize_by_library_id(
        :library_id        => branch.library_id,
        :email             => branch.email,
        :name              => branch.name,
        :user_type_id      => UserType.find_by_code('library').id, 
        :user_sub_type_id  => UserSubType.find_by_code(map_vip_type(branch.type)).id
      )
      unless user.persisted?
        user.password = user.password_confirmation = SecureRandom.base64(12)
      end
      if branch.address
        user.address = Address.find_or_create_by_id(
          :id       => user.address_id,
          :line1    => branch.name,
          :line2    => branch.address,
          :zipcode  => branch.zip,
          :cityname => branch.city)
      elsif user.address
        user.address.destroy
      end
      user.save || logger.warn("Cannot create or update IllUser for library id: #{branch.library_id}")
    end
  end

  
  def first_name
    name
  end

  def last_name
    ''
  end

  def gender
    ''
  end

  def expand
    @expanded = {:address => address}
  end

  def cas_username
    "ILL-#{id}"
  end

  def librarycard
    nil
  end

  private

  def self.map_vip_type(vip_type)
    {
      'Forskningsbibliotek' => 'research_with',
      'Folkebibliotek'      => 'public_dk',
    }[vip_type]
    
  end

end
