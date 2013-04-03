class DeviseCreateAdminUsers < ActiveRecord::Migration
  def change
    create_table(:admin_users) do |t|
      ## CAS authenticable
      t.string   :username, :null => false

      t.timestamps
    end
    add_index :admin_users, :username,             :unique => true
  end
end
