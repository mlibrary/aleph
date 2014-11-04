class AddApplicationsAndRolesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :applications_and_roles, :text, :null => true
  end
end
