class IdentityAddUidIndex < ActiveRecord::Migration
  def change
    add_index :identities, :uid
  end
end
