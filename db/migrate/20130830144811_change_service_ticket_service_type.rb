class ChangeServiceTicketServiceType < ActiveRecord::Migration
  def up
    change_table :service_tickets do |t|
      t.change :service, :text, :limit => nil
    end
  end

  def down
    change_table :service_tickets do |t|
      t.change :service, :string
    end
  end
end
