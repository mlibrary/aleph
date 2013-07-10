class CreateTicketGrantingTicket < ActiveRecord::Migration
  def change
    create_table :ticket_granting_tickets do |t|
      t.string :ticket, :null => false
      t.string :client_hostname, :null => false
      t.string :username, :null => false
      t.text :extra_attributes, :limit => 2048

      t.timestamps
    end

    add_index :ticket_granting_tickets, :ticket
  end
end
