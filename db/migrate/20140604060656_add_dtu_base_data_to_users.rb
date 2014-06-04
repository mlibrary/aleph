class AddDtuBaseDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dtu_base_data, :text, :null => true
  end
end
