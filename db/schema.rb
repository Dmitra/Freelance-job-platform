# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 106) do

  create_table "assets", :force => true do |t|
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "attachable_id"
    t.enum     "attachable_type",   :limit => [:User, :Order, :Solution]
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assets", ["attachable_id", "attachable_type"], :name => "index_assets_on_attachable_id_and_attachable_type"

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.integer "recommended_cost"
  end

  create_table "categorizations", :id => false, :force => true do |t|
    t.integer "order_id",    :null => false
    t.integer "category_id", :null => false
  end

  add_index "categorizations", ["order_id", "category_id"], :name => "index_categorizations_on_order_id_and_category_id", :unique => true

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contributorships", :force => true do |t|
    t.integer  "user_id",         :null => false
    t.integer  "contributor_id",  :null => false
    t.integer  "contribution_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contributorships", ["user_id", "contributor_id", "contribution_id"], :name => "index_c-ships_on_user_id_and_c-tor_id_and_c-ion_id", :unique => true

  create_table "finances", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.string   "paypal",                    :null => false
    t.integer  "quantity",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "position"
    t.integer  "children_count"
    t.integer  "ancestors_count"
    t.integer  "descendants_count"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_copies", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "message_id"
    t.integer  "folder_id"
    t.boolean  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "author_id"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id",                                                                                           :null => false
    t.string   "name"
    t.text     "description"
    t.integer  "solutions_count",                                                               :default => 0,      :null => false
    t.integer  "cost",                                                                                              :null => false
    t.integer  "term",                                                                                              :null => false
    t.enum     "workflow_state",  :limit => [:DRAFT, :BLOCKED, :ACTIVE, :DELETED, :DONE],       :default => :DRAFT
    t.enum     "privacy",         :limit => [:PRIVATE, :GENERAL, :OPEN, :RESTRICTED, :TOPLIST], :default => :OPEN
    t.boolean  "font",                                                                          :default => false
    t.boolean  "color",                                                                         :default => false
    t.integer  "views",                                                                         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "permissions", :id => false, :force => true do |t|
    t.integer  "role_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["role_id", "user_id"], :name => "index_permissions_on_role_id_and_user_id", :unique => true

  create_table "roles", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "solutions", :force => true do |t|
    t.integer  "user_id",                                                                                       :null => false
    t.integer  "order_id",                                                                                      :null => false
    t.text     "body"
    t.text     "description"
    t.binary   "attachments"
    t.enum     "workflow_state", :limit => [:REFUSED, :NEW, :EVALUATED, :ACCEPTED, :DELETED], :default => :NEW
    t.integer  "rating",                                                                      :default => 0
    t.integer  "comments_count",                                                              :default => 0,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "solutions", ["order_id"], :name => "index_solutions_on_order_id"
  add_index "solutions", ["user_id"], :name => "index_solutions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                                                       :null => false
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "enabled",                                   :default => true
    t.string   "surname",                   :limit => 40
    t.date     "birth_date"
    t.boolean  "gender"
    t.string   "city",                      :limit => 40
    t.string   "country",                   :limit => 40
    t.text     "about"
    t.binary   "avatar"
    t.string   "homepage",                  :limit => 1000
    t.binary   "portfolio"
    t.boolean  "spam"
  end

  add_index "users", ["login"], :name => "index_users_on_login"

  create_table "watchlist", :id => false, :force => true do |t|
    t.integer "watcher",  :null => false
    t.integer "order_id", :null => false
  end

  add_index "watchlist", ["watcher", "order_id"], :name => "index_watchlist_on_watcher_and_order_id", :unique => true

end
