class AddUserAuthenticator < ActiveRecord::Migration
  def up
    add_column :users, :authenticator, :string
  end

  def down
    remove_column :users, :authenticator
  end
end
