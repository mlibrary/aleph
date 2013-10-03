# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140117065846) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "addresses", :force => true do |t|
    t.string   "line1",      :null => false
    t.string   "line2",      :null => false
    t.string   "line3"
    t.string   "line4"
    t.string   "line5"
    t.string   "line6"
    t.string   "zipcode",    :null => false
    t.string   "cityname",   :null => false
    t.string   "country"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "admin_users", :force => true do |t|
    t.string   "username",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "admin_users", ["username"], :name => "index_admin_users_on_username", :unique => true

  create_table "dk_nemid_users", :force => true do |t|
    t.string   "identifier",                         :null => false
    t.string   "encrypted_password", :default => "", :null => false
    t.string   "cvr"
    t.string   "cpr"
    t.integer  "user_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "dk_nemid_users", ["identifier"], :name => "index_dk_nemid_users_on_identifier", :unique => true
  add_index "dk_nemid_users", ["user_id"], :name => "index_dk_nemid_users_on_user_id"

  create_table "identities", :force => true do |t|
    t.string   "provider",   :null => false
    t.string   "uid",        :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "identities", ["uid"], :name => "index_identities_on_uid"
  add_index "identities", ["user_id"], :name => "index_identities_on_user_id"

  create_table "login_tickets", :force => true do |t|
    t.string   "ticket",          :null => false
    t.datetime "consumed"
    t.string   "client_hostname", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "login_tickets", ["ticket"], :name => "index_login_tickets_on_ticket"

  create_table "service_tickets", :force => true do |t|
    t.string   "ticket",                    :null => false
    t.text     "service",                   :null => false
    t.datetime "consumed"
    t.integer  "ticket_granting_ticket_id", :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "service_tickets", ["ticket"], :name => "index_service_tickets_on_ticket"
  add_index "service_tickets", ["ticket_granting_ticket_id"], :name => "index_service_tickets_on_ticket_granting_ticket_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "ticket_granting_tickets", :force => true do |t|
    t.string   "ticket",                           :null => false
    t.string   "client_hostname",                  :null => false
    t.string   "username",                         :null => false
    t.text     "extra_attributes", :limit => 2048
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "ticket_granting_tickets", ["ticket"], :name => "index_ticket_granting_tickets_on_ticket"

  create_table "user_sub_types", :force => true do |t|
    t.string   "code",             :null => false
    t.integer  "user_type_id",     :null => false
    t.integer  "aleph_bor_status"
    t.integer  "aleph_bor_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "user_types", :force => true do |t|
    t.string   "code",                            :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "aleph_bor_status", :default => 0, :null => false
    t.integer  "aleph_bor_type",   :default => 0, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "user_type_id"
    t.string   "authenticator"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "address_id"
    t.integer  "user_sub_type_id"
  end

  add_index "users", ["address_id"], :name => "index_users_on_address_id"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["user_sub_type_id"], :name => "index_users_on_user_sub_type_id"
  add_index "users", ["user_type_id"], :name => "index_users_on_user_type_id"

end
