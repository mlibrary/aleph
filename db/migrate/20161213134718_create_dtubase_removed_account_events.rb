class CreateDtubaseRemovedAccountEvents < ActiveRecord::Migration
  def change
    create_table :dtubase_removed_account_events do |t|
      t.string :removed_matrikel_id
      t.string :new_matrikel_id
      t.string :date_removed
    end
  end
end
