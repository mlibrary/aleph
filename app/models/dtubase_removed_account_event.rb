class DtubaseRemovedAccountEvent < ActiveRecord::Base
  attr_accessible :removed_matrikel_id, :new_matrikel_id, :date_removed
  validates :removed_matrikel_id, :presence => true
  validates :new_matrikel_id, :presence => true
end
