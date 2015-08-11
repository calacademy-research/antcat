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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150810170508) do

  create_table "antwiki_valid_taxa", id: false, force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "subfamilia",            limit: 255
    t.string   "tribus",                limit: 255
    t.string   "genus",                 limit: 255
    t.string   "species",               limit: 255
    t.string   "binomial",              limit: 255
    t.string   "binomial_authority",    limit: 255
    t.string   "subspecies",            limit: 255
    t.string   "trinomial",             limit: 255
    t.string   "trinomial_authority",   limit: 255
    t.string   "author",                limit: 255
    t.string   "year",                  limit: 255
    t.string   "changed_comb",          limit: 255
    t.string   "type_locality_country", limit: 255
    t.string   "source",                limit: 255
    t.string   "images",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "author_names", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified"
    t.integer  "author_id",      limit: 4
    t.boolean  "auto_generated",             default: false
    t.string   "origin",         limit: 255
  end

  add_index "author_names", ["author_id"], name: "author_names_author_id_idx", using: :btree
  add_index "author_names", ["created_at", "name"], name: "author_created_at_name", using: :btree
  add_index "author_names", ["name"], name: "author_name_idx", using: :btree

  create_table "authors", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bolton_matches", force: :cascade do |t|
    t.integer  "bolton_reference_id", limit: 4
    t.integer  "reference_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "similarity",          limit: 24
  end

  add_index "bolton_matches", ["bolton_reference_id"], name: "bolton_matches_bolton_reference_id_idx", using: :btree
  add_index "bolton_matches", ["reference_id"], name: "bolton_matches_reference_id_idx", using: :btree

  create_table "bolton_references", force: :cascade do |t|
    t.string   "authors",             limit: 255
    t.string   "note",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",               limit: 255
    t.string   "journal",             limit: 255
    t.string   "series_volume_issue", limit: 255
    t.string   "pagination",          limit: 255
    t.string   "reference_type",      limit: 255
    t.integer  "year",                limit: 4
    t.string   "citation_year",       limit: 255
    t.string   "publisher",           limit: 255
    t.string   "place",               limit: 255
    t.text     "original",            limit: 65535
    t.integer  "match_id",            limit: 4
    t.string   "match_status",        limit: 255
    t.string   "key_cache",           limit: 255
    t.string   "import_result",       limit: 255
  end

  add_index "bolton_references", ["match_id"], name: "index_bolton_references_on_match_id", using: :btree

  create_table "changes", force: :cascade do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "approver_id",           limit: 4
    t.datetime "approved_at"
    t.string   "change_type",           limit: 255
    t.integer  "user_changed_taxon_id", limit: 4
  end

  add_index "changes", ["approver_id"], name: "index_changes_on_approver_id", using: :btree

  create_table "citations", force: :cascade do |t|
    t.integer  "reference_id",   limit: 4
    t.string   "pages",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes_taxt",     limit: 65535
    t.string   "forms",          limit: 255
    t.boolean  "auto_generated",               default: false
    t.string   "origin",         limit: 255
  end

  add_index "citations", ["reference_id"], name: "index_authorships_on_reference_id", using: :btree

  create_table "forward_refs", force: :cascade do |t|
    t.integer  "fixee_id",        limit: 4
    t.string   "fixee_attribute", limit: 255
    t.integer  "genus_id",        limit: 4
    t.string   "epithet",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fixee_type",      limit: 255
    t.string   "type",            limit: 255
    t.integer  "name_id",         limit: 4
  end

  add_index "forward_refs", ["fixee_id", "fixee_type"], name: "index_forward_refs_on_fixee_id_and_fixee_type", using: :btree
  add_index "forward_refs", ["name_id"], name: "index_forward_refs_on_name_id", using: :btree

  create_table "hol_data", force: :cascade do |t|
    t.integer "tnuid",                  limit: 4
    t.integer "tnid",                   limit: 4
    t.string  "name",                   limit: 255
    t.string  "lsid",                   limit: 255
    t.string  "author",                 limit: 255
    t.string  "rank",                   limit: 255
    t.string  "status",                 limit: 255
    t.string  "is_valid",               limit: 255
    t.boolean "fossil"
    t.integer "num_spms",               limit: 4
    t.boolean "many_antcat_references"
    t.boolean "many_hol_references"
  end

  add_index "hol_data", ["tnuid"], name: "hol_data_tnuid_idx", using: :btree

  create_table "hol_literature_pages", force: :cascade do |t|
    t.integer "literatures_id", limit: 4
    t.string  "url",            limit: 255
    t.string  "page",           limit: 255
  end

  create_table "hol_literatures", force: :cascade do |t|
    t.integer "tnuid",     limit: 4
    t.integer "pub_id",    limit: 4
    t.string  "taxon",     limit: 255
    t.string  "name",      limit: 255
    t.string  "describer", limit: 255
    t.string  "rank",      limit: 255
    t.string  "year",      limit: 255
    t.string  "month",     limit: 255
    t.string  "comments",  limit: 255
    t.string  "full_pdf",  limit: 255
    t.string  "pages",     limit: 255
    t.string  "public",    limit: 255
    t.string  "author",    limit: 255
  end

  create_table "hol_synonyms", force: :cascade do |t|
    t.integer "tnuid",      limit: 4
    t.integer "synonym_id", limit: 4
    t.text    "json",       limit: 4294967295
  end

  create_table "hol_taxon_data", force: :cascade do |t|
    t.integer "tnuid",               limit: 4
    t.text    "json",                limit: 4294967295
    t.string  "author_last_name",    limit: 255
    t.integer "antcat_author_id",    limit: 4
    t.string  "journal_name",        limit: 255
    t.integer "hol_journal_id",      limit: 4
    t.integer "antcat_journal_id",   limit: 4
    t.integer "year",                limit: 4
    t.integer "hol_pub_id",          limit: 4
    t.integer "start_page",          limit: 4
    t.integer "end_page",            limit: 4
    t.integer "antcat_protonym_id",  limit: 4
    t.integer "antcat_reference_id", limit: 4
    t.integer "antcat_name_id",      limit: 4
    t.integer "antcat_citation_id",  limit: 4
    t.string  "rank",                limit: 255
    t.string  "rel_type",            limit: 255
    t.boolean "fossil"
    t.string  "status",              limit: 255
    t.integer "antcat_taxon_id",     limit: 4
    t.integer "valid_tnuid",         limit: 4
    t.string  "name",                limit: 255
    t.string  "is_valid",            limit: 255
  end

  add_index "hol_taxon_data", ["antcat_name_id"], name: "hol_taxon_data_antcat_name_id_idx", using: :btree
  add_index "hol_taxon_data", ["antcat_taxon_id"], name: "hol_taxon_data_antcat_taxon_id_idx", using: :btree
  add_index "hol_taxon_data", ["tnuid"], name: "hol_taxon_data_tnuid_idx", using: :btree

  create_table "journals", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_generated",             default: false
    t.string   "origin",         limit: 255
  end

  add_index "journals", ["name"], name: "journals_name_idx", using: :btree

  create_table "names", force: :cascade do |t|
    t.string   "type",               limit: 255
    t.string   "name",               limit: 255
    t.string   "name_html",          limit: 255
    t.string   "epithet",            limit: 255
    t.string   "epithet_html",       limit: 255
    t.string   "epithets",           limit: 255
    t.string   "protonym_html",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender",             limit: 255
    t.boolean  "auto_generated",                 default: false
    t.string   "origin",             limit: 255
    t.boolean  "nonconforming_name"
  end

  add_index "names", ["name"], name: "name_name_index", using: :btree

  create_table "places", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "verified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["name"], name: "places_name_idx", using: :btree

  create_table "protonyms", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authorship_id",  limit: 4
    t.boolean  "fossil"
    t.boolean  "sic"
    t.string   "locality",       limit: 255
    t.integer  "name_id",        limit: 4
    t.boolean  "auto_generated",             default: false
    t.string   "origin",         limit: 255
  end

  add_index "protonyms", ["authorship_id"], name: "index_protonyms_on_authorship_id", using: :btree
  add_index "protonyms", ["name_id"], name: "protonyms_name_id_idx", using: :btree

  create_table "publishers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_id",   limit: 4
  end

  add_index "publishers", ["name"], name: "publishers_name_idx", using: :btree
  add_index "publishers", ["place_id"], name: "publishers_place_id_idx", using: :btree

  create_table "reference_author_names", force: :cascade do |t|
    t.integer  "author_name_id", limit: 4
    t.integer  "reference_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",       limit: 4
    t.boolean  "auto_generated",             default: false
    t.string   "origin",         limit: 255
  end

  add_index "reference_author_names", ["author_name_id"], name: "author_participations_author_id_idx", using: :btree
  add_index "reference_author_names", ["reference_id", "position"], name: "author_participations_reference_id_position_idx", using: :btree
  add_index "reference_author_names", ["reference_id"], name: "author_participations_reference_id_idx", using: :btree

  create_table "reference_documents", force: :cascade do |t|
    t.string   "url",            limit: 255
    t.string   "file_file_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reference_id",   limit: 4
    t.boolean  "public"
  end

  add_index "reference_documents", ["reference_id"], name: "documents_reference_id_idx", using: :btree

  create_table "reference_sections", force: :cascade do |t|
    t.integer  "taxon_id",        limit: 4
    t.integer  "position",        limit: 4
    t.string   "title_taxt",      limit: 255
    t.text     "references_taxt", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "subtitle_taxt",   limit: 65535
  end

  add_index "reference_sections", ["taxon_id", "position"], name: "index_reference_sections_on_taxon_id_and_position", using: :btree

  create_table "references", force: :cascade do |t|
    t.integer  "year",                             limit: 4
    t.string   "possess",                          limit: 255
    t.string   "date",                             limit: 255
    t.datetime "created_at"
    t.string   "cite_code",                        limit: 255
    t.datetime "updated_at"
    t.string   "citation_year",                    limit: 255
    t.string   "type",                             limit: 255
    t.integer  "publisher_id",                     limit: 4
    t.integer  "journal_id",                       limit: 4
    t.string   "series_volume_issue",              limit: 255
    t.string   "pagination",                       limit: 255
    t.text     "author_names_string_cache",        limit: 65535
    t.text     "editor_notes",                     limit: 65535
    t.text     "public_notes",                     limit: 65535
    t.text     "taxonomic_notes",                  limit: 65535
    t.text     "title",                            limit: 65535
    t.text     "citation",                         limit: 65535
    t.integer  "nesting_reference_id",             limit: 4
    t.string   "pages_in",                         limit: 255
    t.string   "author_names_suffix",              limit: 255
    t.string   "principal_author_last_name_cache", limit: 255
    t.string   "bolton_key_cache",                 limit: 255
    t.string   "reason_missing",                   limit: 255
    t.string   "key_cache",                        limit: 255
    t.string   "review_state",                     limit: 255
    t.text     "formatted_cache",                  limit: 65535
    t.text     "inline_citation_cache",            limit: 65535
    t.boolean  "auto_generated",                                 default: false
    t.string   "origin",                           limit: 255
  end

  add_index "references", ["author_names_string_cache", "citation_year"], name: "references_author_names_string_citation_year_idx", length: {"author_names_string_cache"=>255, "citation_year"=>nil}, using: :btree
  add_index "references", ["bolton_key_cache"], name: "index_references_on_bolton_citation_key", using: :btree
  add_index "references", ["created_at"], name: "references_created_at_idx", using: :btree
  add_index "references", ["journal_id"], name: "references_journal_id_idx", using: :btree
  add_index "references", ["nesting_reference_id"], name: "references_nested_reference_id_idx", using: :btree
  add_index "references", ["publisher_id"], name: "references_publisher_id_idx", using: :btree
  add_index "references", ["updated_at"], name: "references_updated_at_idx", using: :btree

  create_table "synonyms", force: :cascade do |t|
    t.integer  "senior_synonym_id", limit: 4
    t.integer  "junior_synonym_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_generated",                default: false
    t.string   "origin",            limit: 255
  end

  create_table "taxa", force: :cascade do |t|
    t.string   "type",                            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fossil",                                        default: false, null: false
    t.string   "status",                          limit: 255
    t.integer  "subfamily_id",                    limit: 4
    t.integer  "tribe_id",                        limit: 4
    t.integer  "genus_id",                        limit: 4
    t.integer  "homonym_replaced_by_id",          limit: 4
    t.string   "incertae_sedis_in",               limit: 255
    t.integer  "species_id",                      limit: 4
    t.integer  "protonym_id",                     limit: 4
    t.text     "type_taxt",                       limit: 65535
    t.text     "headline_notes_taxt",             limit: 65535
    t.integer  "subgenus_id",                     limit: 4
    t.boolean  "hong",                                          default: false, null: false
    t.integer  "name_id",                         limit: 4
    t.integer  "type_name_id",                    limit: 4
    t.text     "genus_species_header_notes_taxt", limit: 65535
    t.boolean  "type_fossil"
    t.string   "name_cache",                      limit: 255
    t.string   "name_html_cache",                 limit: 255
    t.boolean  "unresolved_homonym",                            default: false, null: false
    t.integer  "current_valid_taxon_id",          limit: 4
    t.boolean  "ichnotaxon"
    t.boolean  "nomen_nudum"
    t.integer  "family_id",                       limit: 4
    t.string   "verbatim_type_locality",          limit: 255
    t.string   "biogeographic_region",            limit: 255
    t.text     "type_specimen_repository",        limit: 65535
    t.text     "type_specimen_code",              limit: 65535
    t.text     "type_specimen_url",               limit: 65535
    t.string   "authorship_string",               limit: 255
    t.string   "duplicate_type",                  limit: 255
    t.integer  "collision_merge_id",              limit: 4
    t.boolean  "auto_generated",                                default: false
    t.string   "origin",                          limit: 255
    t.boolean  "display",                                       default: true
  end

  add_index "taxa", ["family_id"], name: "index_taxa_on_family_id", using: :btree
  add_index "taxa", ["genus_id"], name: "taxa_genus_id_idx", using: :btree
  add_index "taxa", ["homonym_replaced_by_id"], name: "index_taxa_on_homonym_replaced_by_id", using: :btree
  add_index "taxa", ["homonym_replaced_by_id"], name: "taxa_homonym_resolved_to_id_index", using: :btree
  add_index "taxa", ["id", "type"], name: "taxa_id_and_type_idx", using: :btree
  add_index "taxa", ["name_id"], name: "taxa_name_id_idx", using: :btree
  add_index "taxa", ["protonym_id"], name: "index_taxa_on_protonym_id", using: :btree
  add_index "taxa", ["species_id"], name: "taxa_species_id_index", using: :btree
  add_index "taxa", ["subfamily_id"], name: "taxa_subfamily_id_idx", using: :btree
  add_index "taxa", ["subgenus_id"], name: "index_taxa_on_subgenus_id", using: :btree
  add_index "taxa", ["tribe_id"], name: "taxa_tribe_id_idx", using: :btree
  add_index "taxa", ["type"], name: "taxa_type_idx", using: :btree
  add_index "taxa", ["type_name_id"], name: "index_taxa_on_type_name_id", using: :btree

  create_table "taxon_history_items", force: :cascade do |t|
    t.text     "taxt",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxon_id",   limit: 4
    t.integer  "position",   limit: 4
  end

  add_index "taxon_history_items", ["taxon_id"], name: "index_taxonomic_history_items_on_taxon_id", using: :btree

  create_table "taxon_states", force: :cascade do |t|
    t.integer  "taxon_id",     limit: 4
    t.string   "review_state", limit: 255
    t.boolean  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taxon_states", ["taxon_id"], name: "taxon_states_taxon_id_idx", using: :btree

  create_table "updates", force: :cascade do |t|
    t.string   "class_name", limit: 255
    t.integer  "record_id",  limit: 4
    t.string   "field_name", limit: 255
    t.text     "before",     limit: 65535
    t.text     "after",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: ""
    t.string   "password_salt",          limit: 255, default: ""
    t.string   "reset_password_token",   limit: 255
    t.string   "remember_token",         limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invitation_token",       limit: 20
    t.datetime "invitation_sent_at"
    t.datetime "reset_password_sent_at"
    t.boolean  "can_edit"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",       limit: 4
    t.integer  "invited_by_id",          limit: 4
    t.string   "invited_by_type",        limit: 255
    t.string   "name",                   limit: 255
    t.datetime "invitation_created_at"
    t.boolean  "is_superadmin"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", using: :btree
  add_index "users", ["invited_by_id", "invited_by_type"], name: "index_users_on_invited_by_id_and_invited_by_type", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,   null: false
    t.integer  "item_id",        limit: 4,     null: false
    t.string   "event",          limit: 255,   null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 65535
    t.datetime "created_at"
    t.text     "object_changes", limit: 65535
    t.integer  "change_id",      limit: 4
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
