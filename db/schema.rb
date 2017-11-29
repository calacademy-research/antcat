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

ActiveRecord::Schema.define(version: 20171022020010) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.integer  "user_id",        limit: 4
    t.string   "action",         limit: 255
    t.text     "parameters",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "edit_summary",   limit: 255
    t.boolean  "automated_edit",               default: false
  end

  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

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
  add_index "changes", ["user_changed_taxon_id"], name: "index_changes_on_user_changed_taxon_id", using: :btree

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

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.string   "title",            limit: 255
    t.text     "body",             limit: 65535
    t.string   "subject",          limit: 255
    t.integer  "user_id",          limit: 4,                     null: false
    t.integer  "parent_id",        limit: 4
    t.integer  "lft",              limit: 4
    t.integer  "rgt",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "edited",                         default: false, null: false
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "data_migrations", id: false, force: :cascade do |t|
    t.string "version", limit: 255, null: false
  end

  add_index "data_migrations", ["version"], name: "unique_data_migrations", unique: true, using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "email",      limit: 255
    t.string   "name",       limit: 255
    t.text     "comment",    limit: 65535
    t.string   "ip",         limit: 255
    t.string   "page",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open",                     default: true
  end

  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id", using: :btree

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

  create_table "institutions", force: :cascade do |t|
    t.string   "abbreviation", limit: 255, null: false
    t.string   "name",         limit: 255, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "institutions", ["abbreviation"], name: "index_institutions_on_abbreviation", unique: true, using: :btree

  create_table "issues", force: :cascade do |t|
    t.integer  "closer_id",   limit: 4
    t.integer  "adder_id",    limit: 4
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "open",                      default: true, null: false
  end

  add_index "issues", ["adder_id"], name: "index_issues_on_adder_id", using: :btree
  add_index "issues", ["closer_id"], name: "index_issues_on_closer_id", using: :btree

  create_table "journals", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin",     limit: 255
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

  add_index "names", ["id", "type"], name: "index_names_on_id_and_type", using: :btree
  add_index "names", ["name"], name: "name_name_index", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,                   null: false
    t.integer  "notifier_id",   limit: 4
    t.integer  "attached_id",   limit: 4
    t.string   "attached_type", limit: 255
    t.boolean  "seen",                      default: false, null: false
    t.string   "reason",        limit: 255,                 null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "notifications", ["attached_type", "attached_id"], name: "index_notifications_on_attached_type_and_attached_id", using: :btree
  add_index "notifications", ["notifier_id"], name: "index_notifications_on_notifier_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.string   "name",       limit: 255
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

  create_table "read_marks", force: :cascade do |t|
    t.integer  "readable_id",   limit: 4
    t.string   "readable_type", limit: 255, null: false
    t.integer  "reader_id",     limit: 4
    t.string   "reader_type",   limit: 255, null: false
    t.datetime "timestamp"
  end

  add_index "read_marks", ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", using: :btree

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
    t.string   "date",                             limit: 255
    t.datetime "created_at"
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
    t.string   "reason_missing",                   limit: 255
    t.string   "review_state",                     limit: 255
    t.text     "formatted_cache",                  limit: 65535
    t.text     "inline_citation_cache",            limit: 65535
    t.boolean  "auto_generated",                                 default: false
    t.string   "origin",                           limit: 255
    t.string   "doi",                              limit: 255
  end

  add_index "references", ["author_names_string_cache", "citation_year"], name: "references_author_names_string_citation_year_idx", length: {"author_names_string_cache"=>255, "citation_year"=>nil}, using: :btree
  add_index "references", ["created_at"], name: "references_created_at_idx", using: :btree
  add_index "references", ["id", "type"], name: "index_references_on_id_and_type", using: :btree
  add_index "references", ["journal_id"], name: "references_journal_id_idx", using: :btree
  add_index "references", ["nesting_reference_id"], name: "references_nested_reference_id_idx", using: :btree
  add_index "references", ["publisher_id"], name: "references_publisher_id_idx", using: :btree
  add_index "references", ["updated_at"], name: "references_updated_at_idx", using: :btree

  create_table "site_notices", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "message",    limit: 65535
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "site_notices", ["user_id"], name: "index_site_notices_on_user_id", using: :btree

  create_table "synonyms", force: :cascade do |t|
    t.integer  "senior_synonym_id", limit: 4
    t.integer  "junior_synonym_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_generated",                default: false
    t.string   "origin",            limit: 255
  end

  add_index "synonyms", ["junior_synonym_id", "senior_synonym_id"], name: "index_synonyms_on_junior_synonym_id_and_senior_synonym_id", using: :btree
  add_index "synonyms", ["junior_synonym_id"], name: "index_synonyms_on_junior_synonym_id", using: :btree
  add_index "synonyms", ["senior_synonym_id"], name: "index_synonyms_on_senior_synonym_id", using: :btree

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
    t.text     "verbatim_type_locality",          limit: 65535
    t.string   "biogeographic_region",            limit: 255
    t.text     "type_specimen_repository",        limit: 65535
    t.text     "type_specimen_code",              limit: 65535
    t.text     "type_specimen_url",               limit: 65535
    t.integer  "collision_merge_id",              limit: 4
    t.boolean  "auto_generated",                                default: false
    t.string   "origin",                          limit: 255
    t.boolean  "display",                                       default: true
    t.integer  "hol_id",                          limit: 4
    t.text     "published_type_information",      limit: 65535
    t.text     "additional_type_information",     limit: 65535
    t.text     "type_notes",                      limit: 65535
  end

  add_index "taxa", ["current_valid_taxon_id"], name: "index_taxa_on_current_valid_taxon_id", using: :btree
  add_index "taxa", ["family_id"], name: "index_taxa_on_family_id", using: :btree
  add_index "taxa", ["genus_id"], name: "taxa_genus_id_idx", using: :btree
  add_index "taxa", ["homonym_replaced_by_id"], name: "index_taxa_on_homonym_replaced_by_id", using: :btree
  add_index "taxa", ["homonym_replaced_by_id"], name: "taxa_homonym_resolved_to_id_index", using: :btree
  add_index "taxa", ["id", "type"], name: "taxa_id_and_type_idx", using: :btree
  add_index "taxa", ["name_cache"], name: "index_taxa_on_name_cache", using: :btree
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

  create_table "tooltips", force: :cascade do |t|
    t.string   "key",              limit: 255
    t.text     "text",             limit: 65535
    t.boolean  "key_enabled",                    default: false
    t.string   "selector",         limit: 255
    t.boolean  "selector_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scope",            limit: 255
  end

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
    t.string   "invitation_token",       limit: 255
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

  add_index "versions", ["change_id"], name: "index_versions_on_change_id", using: :btree
  add_index "versions", ["event"], name: "index_versions_on_event", using: :btree
  add_index "versions", ["item_id"], name: "index_versions_on_item_id", using: :btree
  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["whodunnit"], name: "index_versions_on_whodunnit", using: :btree

  add_foreign_key "site_notices", "users"
end
