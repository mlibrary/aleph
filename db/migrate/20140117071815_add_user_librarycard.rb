class AddUserLibrarycard < ActiveRecord::Migration
  def change
    add_column :users, :librarycard, :string
  end

end
