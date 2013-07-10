class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.references :user, null: false

      t.timestamps
    end
    add_index :identities, :user_id
  end
end
