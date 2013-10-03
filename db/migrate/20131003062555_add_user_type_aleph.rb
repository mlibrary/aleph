class AddUserTypeAleph < ActiveRecord::Migration
  def change
    add_column :user_types, :aleph_bor_status, :integer, :default => 0,
      :null => false
    add_column :user_types, :aleph_bor_type, :integer, :default => 0,
      :null => false
  end
end
