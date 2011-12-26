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

ActiveRecord::Schema.define(:version => 20120115224411) do













































  create_table "author_names", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified"
    t.integer  "author_id"
  end

  add_index "author_names", ["author_id"], :name => "author_names_author_id_idx"
  add_index "author_names", ["created_at", "name"], :name => "author_created_at_name"
  add_index "author_names", ["name"], :name => "author_name_idx"

  create_table "authors", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bolton_matches", :force => true do |t|
    t.integer  "bolton_reference_id"
    t.integer  "reference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "similarity"
  end

  add_index "bolton_matches", ["bolton_reference_id"], :name => "bolton_matches_bolton_reference_id_idx"
  add_index "bolton_matches", ["reference_id"], :name => "bolton_matches_reference_id_idx"

  create_table "bolton_references", :force => true do |t|
    t.string   "authors"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "journal"
    t.string   "series_volume_issue"
    t.string   "pagination"
    t.string   "reference_type"
    t.integer  "year"
    t.string   "citation_year"
    t.string   "publisher"
    t.string   "place"
    t.text     "original"
    t.integer  "match_id"
    t.string   "match_status"
    t.string   "key_cache"
    t.string   "import_result"
  end

  create_table "citations", :force => true do |t|
    t.integer  "reference_id"
    t.string   "pages"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "citations", ["reference_id"], :name => "index_authorships_on_reference_id"

  create_table "forward_references", :force => true do |t|
    t.integer "source_id"
    t.string  "source_attribute"
    t.string  "target_name"
  end

  create_table "citations", :force => true do |t|
    t.integer  "reference_id"
    t.string   "pages"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "citations", ["reference_id"], :name => "index_authorships_on_reference_id"

  create_table "forward_references", :force => true do |t|
    t.integer "source_id"
    t.string  "source_attribute"
    t.string  "target_name"
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

  create_table "protonyms", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authorship_id"
    t.string   "rank"
    t.boolean  "fossil"
    t.boolean  "sic"
  end

  add_index "protonyms", ["authorship_id"], :name => "index_protonyms_on_authorship_id"

  create_table "publishers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_id"
  end

  add_index "publishers", ["name"], :name => "publishers_name_idx"
  add_index "publishers", ["place_id"], :name => "publishers_place_id_idx"

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

  create_table "reference_documents", :force => true do |t|
    t.string   "url"
    t.string   "file_file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reference_id"
    t.boolean  "public"
  end

  add_index "reference_documents", ["reference_id"], :name => "documents_reference_id_idx"

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
    t.text     "author_names_string_cache"
    t.text     "editor_notes"
    t.text     "public_notes"
    t.text     "taxonomic_notes"
    t.text     "title"
    t.text     "citation"
    t.integer  "nested_reference_id"
    t.string   "pages_in"
    t.string   "author_names_suffix"
    t.string   "principal_author_last_name_cache"
    t.string   "bolton_key_cache"
    t.string   "reason_missing"
  end

  add_index "references", ["author_names_string_cache", "citation_year"], :name => "references_author_names_string_citation_year_idx", :length => {"author_names_string_cache"=>255, "citation_year"=>nil}
  add_index "references", ["bolton_key_cache"], :name => "index_references_on_bolton_citation_key"
  add_index "references", ["created_at"], :name => "references_created_at_idx"
  add_index "references", ["journal_id"], :name => "references_journal_id_idx"
  add_index "references", ["nested_reference_id"], :name => "references_nested_reference_id_idx"
  add_index "references", ["publisher_id"], :name => "references_publisher_id_idx"
  add_index "references", ["updated_at"], :name => "references_updated_at_idx"

  create_table "taxa", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fossil",                                       :default => false, :null => false
    t.text     "taxonomic_history",      :limit => 2147483647
    t.string   "status"
    t.integer  "subfamily_id"
    t.integer  "tribe_id"
    t.integer  "genus_id"
    t.integer  "synonym_of_id"
    t.integer  "homonym_replaced_by_id"
    t.string   "incertae_sedis_in"
    t.integer  "species_id"
    t.integer  "protonym_id"
    t.integer  "type_taxon_id"
    t.text     "type_taxon_taxt"
  end

  add_index "taxa", ["genus_id"], :name => "taxa_genus_id_idx"
  add_index "taxa", ["homonym_replaced_by_id"], :name => "taxa_homonym_resolved_to_id_index"
  add_index "taxa", ["id", "type"], :name => "taxa_id_and_type_idx"
  add_index "taxa", ["name"], :name => "taxa_name_idx"
  add_index "taxa", ["species_id"], :name => "taxa_species_id_index"
  add_index "taxa", ["subfamily_id"], :name => "taxa_subfamily_id_idx"
  add_index "taxa", ["synonym_of_id"], :name => "taxa_synonym_of_id_index"
  add_index "taxa", ["tribe_id"], :name => "taxa_tribe_id_idx"
  add_index "taxa", ["type"], :name => "taxa_type_idx"

  create_table "taxonomic_history_items", :force => true do |t|
    t.text     "taxt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxon_id"
    t.integer  "position"
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

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
