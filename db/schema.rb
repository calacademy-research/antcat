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

ActiveRecord::Schema.define(:version => 20100915193020) do

  create_table "author_participations", :force => true do |t|
    t.integer  "author_id"
    t.integer  "reference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "author_participations", ["author_id"], :name => "author_participations_author_id_idx"
  add_index "author_participations", ["reference_id"], :name => "foo"

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authors", ["name"], :name => "author_name_idx"

  create_table "bolton_references", :force => true do |t|
    t.string   "authors"
    t.string   "year"
    t.string   "title_and_citation"
    t.string   "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ward_reference_id"
    t.boolean  "suspect"
  end

  create_table "genera", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journals", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publishers", :force => true do |t|
    t.string   "name"
    t.string   "place"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "references", :force => true do |t|
    t.integer  "year"
    t.string   "title"
    t.string   "public_notes"
    t.string   "possess"
    t.string   "date"
    t.datetime "created_at"
    t.string   "cite_code"
    t.datetime "updated_at"
    t.string   "editor_notes"
    t.string   "taxonomic_notes"
    t.string   "citation_year"
    t.string   "type"
    t.integer  "publisher_id"
    t.integer  "journal_id"
    t.string   "series_volume_issue"
    t.string   "pagination"
    t.integer  "source_reference_id"
    t.string   "source_reference_type"
    t.string   "authors_string"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :default => "", :null => false
    t.string   "encrypted_password",                 :default => ""
    t.string   "password_salt",                      :default => ""
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invitation_token",     :limit => 20
    t.datetime "invitation_sent_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "ward_references", :force => true do |t|
    t.string   "authors"
    t.string   "citation"
    t.string   "cite_code"
    t.string   "date"
    t.string   "filename"
    t.string   "notes"
    t.string   "possess"
    t.string   "taxonomic_notes"
    t.string   "title"
    t.string   "year"
    t.integer  "reference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
