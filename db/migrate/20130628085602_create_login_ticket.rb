class CreateLoginTicket < ActiveRecord::Migration
  def change
    create_table :login_tickets do |t|
      t.string :ticket, :null => false
      t.timestamp :consumed
      t.string :client_hostname, :null => false

      t.timestamps
    end

    add_index :login_tickets, :ticket
  end
end
