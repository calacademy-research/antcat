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

ActiveRecord::Schema.define(:version => 20101202043220) do

  create_table "author_names", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified"
    t.integer  "author_id"
  end

  add_index "author_names", ["created_at", "name"], :name => "author_created_at_name"
  add_index "author_names", ["name"], :name => "author_name_idx"

  create_table "authors", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bolton_references", :force => true do |t|
    t.string   "authors"
    t.string   "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ward_reference_id"
    t.boolean  "suspect"
    t.string   "title"
    t.string   "journal"
    t.string   "series_volume_issue"
    t.string   "pagination"
    t.string   "reference_type"
    t.integer  "year"
    t.string   "citation_year"
    t.string   "publisher"
    t.string   "place"
  end

  create_table "genera", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journals", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journals", ["name"], :name => "journals_name_idx"

  create_table "places", :force => true do |t|
    t.string   "name"
    t.boolean  "verified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["name"], :name => "places_name_idx"

  create_table "publishers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_id"
  end

  add_index "publishers", ["name"], :name => "publishers_name_idx"

  create_table "reference_author_names", :force => true do |t|
    t.integer  "author_name_id"
    t.integer  "reference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "reference_author_names", ["author_name_id"], :name => "author_participations_author_id_idx"
  add_index "reference_author_names", ["reference_id", "position"], :name => "author_participations_reference_id_position_idx"
  add_index "reference_author_names", ["reference_id"], :name => "author_participations_reference_id_idx"

  create_table "references", :force => true do |t|
    t.integer  "year"
    t.string   "possess"
    t.string   "date"
    t.datetime "created_at"
    t.string   "cite_code"
    t.datetime "updated_at"
    t.string   "citation_year"
    t.string   "type"
    t.integer  "publisher_id"
    t.integer  "journal_id"
    t.string   "series_volume_issue"
    t.string   "pagination"
    t.integer  "source_reference_id"
    t.string   "source_reference_type"
    t.text     "author_names_string"
    t.text     "editor_notes"
    t.text     "public_notes"
    t.text     "taxonomic_notes"
    t.text     "title"
    t.string   "source_url"
    t.text     "citation"
    t.integer  "nested_reference_id"
    t.string   "pages_in"
    t.string   "author_names_suffix"
    t.string   "source_file_name"
  end

  add_index "references", ["author_names_string", "citation_year"], :name => "references_authors_string_citation_year_idx", :length => {"citation_year"=>nil, "author_names_string"=>"100"}

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

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "ward_references", :force => true do |t|
    t.string   "cite_code"
    t.string   "date"
    t.string   "filename"
    t.string   "possess"
    t.string   "year"
    t.integer  "reference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "authors"
    t.text     "citation"
    t.text     "notes"
    t.text     "taxonomic_notes"
    t.text     "title"
    t.text     "editor_notes"
  end

end
