class AddUserTermAndAddress < ActiveRecord::Migration
  def change
    add_column :users, :accept_payment_terms, :boolean, :default => false
    add_column :users, :accept_printed_terms, :boolean, :default => false
    add_column :users, :address_id, :integer
    add_index :users, :address_id
  end
end
