class AddUserSubTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_sub_type_id, :integer
    add_index :users, :user_sub_type_id
  end
end
