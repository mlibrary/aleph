# Class for login into NemId.
# If already logged in as User, connect NemId identity to user.
# TODO:
#   If not logged in, ask addtional information and create and connect User.
class DkNemidUser < ActiveRecord::Base
  devise :dk_nemid, :authentication_keys => [:identifier]

  attr_accessible :identifier, :user, :cvr, :cpr
  belongs_to :user

end
