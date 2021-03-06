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

ActiveRecord::Schema.define(:version => 20140615102223) do

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "authors_books", :force => true do |t|
    t.integer "author_id"
    t.integer "book_id"
  end

  create_table "book_choices", :force => true do |t|
    t.integer  "user_id"
    t.integer  "round_id"
    t.integer  "book_id"
    t.string   "state"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "games_user_id"
  end

  create_table "books", :force => true do |t|
    t.string   "title"
    t.text     "image_url"
    t.text     "synopsis"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.text     "pre_first_line_content"
    t.string   "source"
  end

  create_table "first_lines", :force => true do |t|
    t.text     "text"
    t.integer  "book_id"
    t.boolean  "true_line"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "user_id"
    t.integer  "introductory_content_id"
    t.string   "state"
    t.integer  "games_user_id"
  end

  create_table "first_lines_rounds", :force => true do |t|
    t.integer  "first_line_id"
    t.integer  "round_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "games", :force => true do |t|
    t.string   "type"
    t.string   "state"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "kind"
  end

  create_table "games_users", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.string   "invitation_status"
    t.string   "user_role"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "introductory_contents", :force => true do |t|
    t.integer  "book_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "line_choices", :force => true do |t|
    t.integer  "first_line_id"
    t.integer  "user_id"
    t.integer  "round_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "state"
    t.integer  "games_user_id"
  end

  create_table "notifications", :force => true do |t|
    t.text     "text"
    t.integer  "user_id"
    t.boolean  "checked"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "other_lines", :force => true do |t|
    t.string   "kind"
    t.text     "text"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "introductory_content_id"
  end

  create_table "rounds", :force => true do |t|
    t.integer  "game_id"
    t.string   "state"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "username",               :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "nickname",               :default => ""
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
