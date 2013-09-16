class CreateAdddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :line1, :null => false
      t.string :line2, :null => false
      t.string :line3
      t.string :line4
      t.string :line5
      t.string :line6
      t.string :zipcode, :null => false
      t.string :cityname, :null => false
      t.string :country

      t.timestamps
    end
  end
end
