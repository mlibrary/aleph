class CreateDkNemidUsers < ActiveRecord::Migration
  def change
    create_table(:dk_nemid_users) do |t|
      t.string :identifier, :null => false
      t.string :encrypted_password, :null => false, :default => ""
      t.string :cvr
      t.string :cpr
      t.references :user

      t.timestamps
    end
    add_index :dk_nemid_users, :identifier, :unique => true
    add_index :dk_nemid_users, :user_id
  end

end
