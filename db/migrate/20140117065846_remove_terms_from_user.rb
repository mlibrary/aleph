class RemoveTermsFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :accept_payment_terms
    remove_column :users, :accept_printed_terms
  end

  def down
    raise UnsupportedMigration
  end
end
