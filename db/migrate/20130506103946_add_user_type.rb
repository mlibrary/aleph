class AddUserType < ActiveRecord::Migration
  def up
    add_column  :users, :user_type_id, :integer
    add_index   :users, :user_type_id
  end

  def down
    remove_column :users, :user_type_id
  end
end
