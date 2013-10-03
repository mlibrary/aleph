class CreateUserSubTypes < ActiveRecord::Migration
  def change
    create_table :user_sub_types do |t|
      t.string :code, :null => false
      t.references :user_type, :null => false
      t.integer :aleph_bor_status
      t.integer :aleph_bor_type

      t.timestamps
    end
  end
end
