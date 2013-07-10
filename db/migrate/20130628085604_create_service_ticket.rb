class CreateServiceTicket < ActiveRecord::Migration
  def change
    create_table :service_tickets do |t|
      t.string :ticket, :null => false
      t.string :service, :null => false
      t.timestamp :consumed
      t.references :ticket_granting_ticket, :null => false

      t.timestamps
    end

    add_index :service_tickets, :ticket
    add_index :service_tickets, :ticket_granting_ticket_id
  end
end
