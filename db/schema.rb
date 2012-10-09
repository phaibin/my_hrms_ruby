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

ActiveRecord::Schema.define(:version => 20121009094415) do

  create_table "group_permissions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "permission_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "group_permissions", ["group_id"], :name => "index_group_permissions_on_group_id"
  add_index "group_permissions", ["permission_id"], :name => "index_group_permissions_on_permission_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "overtime_flows", :force => true do |t|
    t.integer  "overtime_id"
    t.integer  "applicant_id"
    t.integer  "parent_id"
    t.boolean  "can_read"
    t.boolean  "can_update"
    t.boolean  "can_delete"
    t.boolean  "can_apply"
    t.boolean  "can_revoke"
    t.boolean  "can_reject"
    t.boolean  "can_approve"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "overtime_flows", ["overtime_id"], :name => "index_overtime_flows_on_overtime_id"

  create_table "overtime_states", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "overtimes", :force => true do |t|
    t.string   "subject"
    t.date     "start_time"
    t.date     "end_time"
    t.integer  "state_id"
    t.integer  "applicant_id"
    t.text     "content"
    t.integer  "modified_by"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "overtimes", ["applicant_id"], :name => "index_overtimes_on_applicant_id"
  add_index "overtimes", ["modified_by"], :name => "index_overtimes_on_modified_by"

  create_table "permissions", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_groups", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "chinese_name"
    t.string   "english_name"
    t.integer  "superior_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
