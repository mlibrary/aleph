class CreateIllUsers < ActiveRecord::Migration
  def change
    create_table :ill_users do |t|
      ## Database authenticatable
      t.string :library_id,         :null => false
      t.string :name,               :null => false
      t.string :email,              :null => false
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Lockable
      t.integer  :failed_attempts, :default => 0 # Only if lock strategy is
                                                 # :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.references :user_type,     :null => false
      t.references :user_sub_type, :null => false
      t.references :address,       :null => true

      t.timestamps
    end

    add_index :ill_users, :library_id,           :unique => true
    add_index :ill_users, :reset_password_token, :unique => true
    add_index :ill_users, :user_type_id,         :unique => false
    add_index :ill_users, :user_sub_type_id,     :unique => false
    add_index :ill_users, :address_id,           :unique => false
  end
end
