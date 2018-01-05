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

ActiveRecord::Schema.define(version: 20171231030837) do

  create_table "activities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "user_id"
    t.string   "action"
    t.text     "parameters",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "edit_summary"
    t.boolean  "automated_edit",               default: false
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "author_names", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified"
    t.integer  "author_id"
    t.boolean  "auto_generated", default: false
    t.string   "origin"
    t.index ["author_id"], name: "author_names_author_id_idx", using: :btree
    t.index ["created_at", "name"], name: "author_created_at_name", using: :btree
    t.index ["name"], name: "author_name_idx", using: :btree
  end

  create_table "authors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bolton_matches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "bolton_reference_id"
    t.integer  "reference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "similarity",          limit: 24
    t.index ["bolton_reference_id"], name: "bolton_matches_bolton_reference_id_idx", using: :btree
    t.index ["reference_id"], name: "bolton_matches_reference_id_idx", using: :btree
  end

  create_table "bolton_references", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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
    t.text     "original",            limit: 65535
    t.integer  "match_id"
    t.string   "match_status"
    t.string   "key_cache"
    t.string   "import_result"
    t.index ["match_id"], name: "index_bolton_references_on_match_id", using: :btree
  end

  create_table "changes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "approver_id"
    t.datetime "approved_at"
    t.string   "change_type"
    t.integer  "user_changed_taxon_id"
    t.integer  "user_id"
    t.index ["approver_id"], name: "index_changes_on_approver_id", using: :btree
    t.index ["user_changed_taxon_id"], name: "index_changes_on_user_changed_taxon_id", using: :btree
  end

  create_table "citations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "reference_id"
    t.string   "pages"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes_taxt",     limit: 65535
    t.string   "forms"
    t.boolean  "auto_generated",               default: false
    t.string   "origin"
    t.index ["reference_id"], name: "index_authorships_on_reference_id", using: :btree
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body",             limit: 65535
    t.string   "subject"
    t.integer  "user_id",                                        null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "edited",                         default: false, null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "data_migrations", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "version", null: false
    t.index ["version"], name: "unique_data_migrations", unique: true, using: :btree
  end

  create_table "feedbacks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "name"
    t.text     "comment",    limit: 65535
    t.string   "ip"
    t.string   "page"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open",                     default: true
    t.index ["user_id"], name: "index_feedbacks_on_user_id", using: :btree
  end

  create_table "forward_refs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "fixee_id"
    t.string   "fixee_attribute"
    t.integer  "genus_id"
    t.string   "epithet"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fixee_type"
    t.string   "type"
    t.integer  "name_id"
    t.index ["fixee_id", "fixee_type"], name: "index_forward_refs_on_fixee_id_and_fixee_type", using: :btree
    t.index ["name_id"], name: "index_forward_refs_on_name_id", using: :btree
  end

  create_table "institutions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "abbreviation", null: false
    t.string   "name",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["abbreviation"], name: "index_institutions_on_abbreviation", unique: true, using: :btree
  end

  create_table "issues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "closer_id"
    t.integer  "adder_id"
    t.string   "title"
    t.text     "description", limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "open",                      default: true, null: false
    t.index ["adder_id"], name: "index_issues_on_adder_id", using: :btree
    t.index ["closer_id"], name: "index_issues_on_closer_id", using: :btree
  end

  create_table "journals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin"
    t.index ["name"], name: "journals_name_idx", using: :btree
  end

  create_table "names", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "type"
    t.string   "name"
    t.string   "name_html"
    t.string   "epithet"
    t.string   "epithet_html"
    t.string   "epithets"
    t.string   "protonym_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender"
    t.boolean  "auto_generated",     default: false
    t.string   "origin"
    t.boolean  "nonconforming_name"
    t.index ["id", "type"], name: "index_names_on_id_and_type", using: :btree
    t.index ["name"], name: "name_name_index", using: :btree
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",                       null: false
    t.integer  "notifier_id"
    t.integer  "attached_id"
    t.string   "attached_type"
    t.boolean  "seen",          default: false, null: false
    t.string   "reason",                        null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["attached_type", "attached_id"], name: "index_notifications_on_attached_type_and_attached_id", using: :btree
    t.index ["notifier_id"], name: "index_notifications_on_notifier_id", using: :btree
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "places", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "places_name_idx", using: :btree
  end

  create_table "protonyms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authorship_id"
    t.boolean  "fossil"
    t.boolean  "sic"
    t.string   "locality"
    t.integer  "name_id"
    t.boolean  "auto_generated", default: false
    t.string   "origin"
    t.index ["authorship_id"], name: "index_protonyms_on_authorship_id", using: :btree
    t.index ["name_id"], name: "protonyms_name_id_idx", using: :btree
  end

  create_table "publishers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_id"
    t.index ["name"], name: "publishers_name_idx", using: :btree
    t.index ["place_id"], name: "publishers_place_id_idx", using: :btree
  end

  create_table "read_marks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "readable_id"
    t.string   "readable_type", null: false
    t.integer  "reader_id"
    t.string   "reader_type",   null: false
    t.datetime "timestamp"
    t.index ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", using: :btree
  end

  create_table "reference_author_names", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "author_name_id"
    t.integer  "reference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "auto_generated", default: false
    t.string   "origin"
    t.index ["author_name_id"], name: "author_participations_author_id_idx", using: :btree
    t.index ["reference_id", "position"], name: "author_participations_reference_id_position_idx", using: :btree
    t.index ["reference_id"], name: "author_participations_reference_id_idx", using: :btree
  end

  create_table "reference_documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "url"
    t.string   "file_file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reference_id"
    t.boolean  "public"
    t.index ["reference_id"], name: "documents_reference_id_idx", using: :btree
  end

  create_table "reference_sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "taxon_id"
    t.integer  "position"
    t.string   "title_taxt"
    t.text     "references_taxt", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "subtitle_taxt",   limit: 65535
    t.index ["taxon_id", "position"], name: "index_reference_sections_on_taxon_id_and_position", using: :btree
  end

  create_table "references", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "year"
    t.string   "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "citation_year"
    t.string   "type"
    t.integer  "publisher_id"
    t.integer  "journal_id"
    t.string   "series_volume_issue"
    t.string   "pagination"
    t.text     "author_names_string_cache",        limit: 65535
    t.text     "editor_notes",                     limit: 65535
    t.text     "public_notes",                     limit: 65535
    t.text     "taxonomic_notes",                  limit: 65535
    t.text     "title",                            limit: 65535
    t.text     "citation",                         limit: 65535
    t.integer  "nesting_reference_id"
    t.string   "pages_in"
    t.string   "author_names_suffix"
    t.string   "principal_author_last_name_cache"
    t.string   "reason_missing"
    t.string   "review_state"
    t.text     "formatted_cache",                  limit: 65535
    t.text     "inline_citation_cache",            limit: 65535
    t.boolean  "auto_generated",                                 default: false
    t.string   "origin"
    t.string   "doi"
    t.index ["author_names_string_cache", "citation_year"], name: "references_author_names_string_citation_year_idx", length: {"author_names_string_cache"=>255, "citation_year"=>nil}, using: :btree
    t.index ["created_at"], name: "references_created_at_idx", using: :btree
    t.index ["id", "type"], name: "index_references_on_id_and_type", using: :btree
    t.index ["journal_id"], name: "references_journal_id_idx", using: :btree
    t.index ["nesting_reference_id"], name: "references_nested_reference_id_idx", using: :btree
    t.index ["publisher_id"], name: "references_publisher_id_idx", using: :btree
    t.index ["updated_at"], name: "references_updated_at_idx", using: :btree
  end

  create_table "site_notices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.text     "message",    limit: 65535
    t.integer  "user_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["user_id"], name: "index_site_notices_on_user_id", using: :btree
  end

  create_table "synonyms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "senior_synonym_id"
    t.integer  "junior_synonym_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_generated",    default: false
    t.string   "origin"
    t.index ["junior_synonym_id", "senior_synonym_id"], name: "index_synonyms_on_junior_synonym_id_and_senior_synonym_id", using: :btree
    t.index ["junior_synonym_id"], name: "index_synonyms_on_junior_synonym_id", using: :btree
    t.index ["senior_synonym_id"], name: "index_synonyms_on_senior_synonym_id", using: :btree
  end

  create_table "taxa", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fossil",                                        default: false, null: false
    t.string   "status"
    t.integer  "subfamily_id"
    t.integer  "tribe_id"
    t.integer  "genus_id"
    t.integer  "homonym_replaced_by_id"
    t.string   "incertae_sedis_in"
    t.integer  "species_id"
    t.integer  "protonym_id"
    t.text     "type_taxt",                       limit: 65535
    t.text     "headline_notes_taxt",             limit: 65535
    t.integer  "subgenus_id"
    t.boolean  "hong",                                          default: false, null: false
    t.integer  "name_id"
    t.integer  "type_name_id"
    t.text     "genus_species_header_notes_taxt", limit: 65535
    t.boolean  "type_fossil"
    t.string   "name_cache"
    t.string   "name_html_cache"
    t.boolean  "unresolved_homonym",                            default: false, null: false
    t.integer  "current_valid_taxon_id"
    t.boolean  "ichnotaxon"
    t.boolean  "nomen_nudum"
    t.integer  "family_id"
    t.text     "verbatim_type_locality",          limit: 65535
    t.string   "biogeographic_region"
    t.text     "type_specimen_repository",        limit: 65535
    t.text     "type_specimen_code",              limit: 65535
    t.text     "type_specimen_url",               limit: 65535
    t.integer  "collision_merge_id"
    t.boolean  "auto_generated",                                default: false
    t.string   "origin"
    t.boolean  "display",                                       default: true
    t.integer  "hol_id"
    t.text     "published_type_information",      limit: 65535
    t.text     "additional_type_information",     limit: 65535
    t.text     "type_notes",                      limit: 65535
    t.index ["current_valid_taxon_id"], name: "index_taxa_on_current_valid_taxon_id", using: :btree
    t.index ["family_id"], name: "index_taxa_on_family_id", using: :btree
    t.index ["genus_id"], name: "taxa_genus_id_idx", using: :btree
    t.index ["homonym_replaced_by_id"], name: "index_taxa_on_homonym_replaced_by_id", using: :btree
    t.index ["homonym_replaced_by_id"], name: "taxa_homonym_resolved_to_id_index", using: :btree
    t.index ["id", "type"], name: "taxa_id_and_type_idx", using: :btree
    t.index ["name_cache"], name: "index_taxa_on_name_cache", using: :btree
    t.index ["name_id"], name: "taxa_name_id_idx", using: :btree
    t.index ["protonym_id"], name: "index_taxa_on_protonym_id", using: :btree
    t.index ["species_id"], name: "taxa_species_id_index", using: :btree
    t.index ["subfamily_id"], name: "taxa_subfamily_id_idx", using: :btree
    t.index ["subgenus_id"], name: "index_taxa_on_subgenus_id", using: :btree
    t.index ["tribe_id"], name: "taxa_tribe_id_idx", using: :btree
    t.index ["type"], name: "taxa_type_idx", using: :btree
    t.index ["type_name_id"], name: "index_taxa_on_type_name_id", using: :btree
  end

  create_table "taxon_history_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.text     "taxt",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxon_id"
    t.integer  "position"
    t.index ["taxon_id"], name: "index_taxonomic_history_items_on_taxon_id", using: :btree
  end

  create_table "taxon_states", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "taxon_id"
    t.string   "review_state"
    t.boolean  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["taxon_id"], name: "taxon_states_taxon_id_idx", using: :btree
  end

  create_table "tooltips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "key"
    t.text     "text",             limit: 65535
    t.boolean  "key_enabled",                    default: false
    t.string   "selector"
    t.boolean  "selector_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scope"
  end

  create_table "updates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "class_name"
    t.integer  "record_id"
    t.string   "field_name"
    t.text     "before",     limit: 65535
    t.text     "after",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "password_salt",          default: ""
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "reset_password_sent_at"
    t.boolean  "can_edit"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "name"
    t.datetime "invitation_created_at"
    t.boolean  "is_superadmin"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", using: :btree
    t.index ["invited_by_id", "invited_by_type"], name: "index_users_on_invited_by_id_and_invited_by_type", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "item_type",                    null: false
    t.integer  "item_id",                      null: false
    t.string   "event",                        null: false
    t.string   "whodunnit"
    t.text     "object",         limit: 65535
    t.datetime "created_at"
    t.text     "object_changes", limit: 65535
    t.integer  "change_id"
    t.index ["change_id"], name: "index_versions_on_change_id", using: :btree
    t.index ["event"], name: "index_versions_on_event", using: :btree
    t.index ["item_id"], name: "index_versions_on_item_id", using: :btree
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
    t.index ["whodunnit"], name: "index_versions_on_whodunnit", using: :btree
  end

  add_foreign_key "site_notices", "users"
end
