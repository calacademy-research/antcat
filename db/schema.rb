# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_21_204003) do

  create_table "activities", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "trackable_id"
    t.string "trackable_type"
    t.integer "user_id"
    t.string "action", null: false
    t.text "parameters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "edit_summary"
    t.boolean "automated_edit", default: false, null: false
    t.string "request_uuid"
    t.index ["request_uuid"], name: "ix_activities__request_uuid"
    t.index ["trackable_id", "trackable_type"], name: "ix_activities__trackable_id__trackable_type"
    t.index ["user_id"], name: "ix_activities__user_id"
  end

  create_table "author_names", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "author_id", null: false
    t.index ["author_id"], name: "ix_author_names__author_id"
    t.index ["created_at", "name"], name: "ix_author_names__created_at__name"
    t.index ["name"], name: "ix_author_names__name"
  end

  create_table "authors", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "citations", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "reference_id", null: false
    t.string "pages", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference_id"], name: "ix_citations__reference_id"
  end

  create_table "comments", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.text "body", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "edited", default: false, null: false
    t.index ["commentable_id", "commentable_type"], name: "ix_comments__commentable_id__commentable_type"
    t.index ["user_id"], name: "ix_comments__user_id"
  end

  create_table "feedbacks", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.string "name"
    t.text "comment", null: false
    t.string "ip"
    t.string "page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "open", default: true, null: false
    t.index ["user_id"], name: "ix_feedbacks__user_id"
  end

  create_table "history_items", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "taxt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", null: false
    t.string "rank"
    t.integer "protonym_id", null: false
    t.string "type", default: "Taxt", null: false
    t.string "subtype"
    t.string "picked_value"
    t.string "text_value"
    t.integer "reference_id"
    t.string "pages"
    t.integer "object_protonym_id"
    t.integer "object_taxon_id"
    t.boolean "force_author_citation", default: false, null: false
    t.index ["object_protonym_id"], name: "ix_history_items__object_protonym_id"
    t.index ["object_taxon_id"], name: "ix_history_items__object_taxon_id"
    t.index ["protonym_id"], name: "ix_history_items__protonym_id"
    t.index ["reference_id"], name: "ix_history_items__reference_id"
    t.index ["subtype"], name: "ix_history_items__subtype"
    t.index ["type"], name: "ix_history_items__type"
  end

  create_table "institutions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "abbreviation", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "grscicoll_identifier"
    t.index ["abbreviation"], name: "ux_institutions__abbreviation", unique: true
  end

  create_table "issues", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "closer_id"
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "open", default: true, null: false
    t.boolean "help_wanted", default: false, null: false
    t.index ["closer_id"], name: "ix_issues__closer_id"
    t.index ["user_id"], name: "ix_issues__user_id"
  end

  create_table "journals", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "ux_journals__name", unique: true
  end

  create_table "names", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.string "epithet", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gender"
    t.string "cleaned_name", null: false
    t.boolean "non_conforming", default: false, null: false
    t.index ["id", "type"], name: "ix_names__id__type"
    t.index ["name"], name: "ix_names__name"
  end

  create_table "notifications", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "notifier_id"
    t.integer "attached_id"
    t.string "attached_type"
    t.boolean "seen", default: false, null: false
    t.string "reason", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attached_type", "attached_id"], name: "ix_notifications__attached_type__attached_id"
    t.index ["notifier_id"], name: "ix_notifications__notifier_id"
    t.index ["user_id"], name: "ix_notifications__user_id"
  end

  create_table "protonyms", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "authorship_id", null: false
    t.boolean "fossil", default: false, null: false
    t.boolean "sic", default: false, null: false
    t.string "locality"
    t.integer "name_id", null: false
    t.text "primary_type_information_taxt"
    t.text "secondary_type_information_taxt"
    t.text "type_notes_taxt"
    t.string "biogeographic_region"
    t.boolean "uncertain_locality", default: false, null: false
    t.integer "type_name_id"
    t.string "forms"
    t.text "notes_taxt"
    t.boolean "nomen_novum", default: false, null: false
    t.boolean "nomen_oblitum", default: false, null: false
    t.boolean "nomen_dubium", default: false, null: false
    t.boolean "nomen_conservandum", default: false, null: false
    t.boolean "nomen_protectum", default: false, null: false
    t.boolean "nomen_nudum", default: false, null: false
    t.boolean "ichnotaxon", default: false, null: false
    t.text "etymology_taxt"
    t.string "gender_agreement_type"
    t.index ["authorship_id"], name: "ix_protonyms__authorship_id"
    t.index ["name_id"], name: "ix_protonyms__name_id"
    t.index ["type_name_id"], name: "ux_protonyms__type_name_id", unique: true
  end

  create_table "publishers", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "place", null: false
    t.index ["name", "place"], name: "ux_publishers__name__place", unique: true
    t.index ["name"], name: "ix_publishers__name"
  end

  create_table "read_marks", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "readable_id"
    t.string "readable_type", null: false
    t.integer "reader_id"
    t.string "reader_type", null: false
    t.datetime "timestamp"
    t.index ["reader_id", "reader_type", "readable_type", "readable_id"], name: "ix_x_read_marks__reader_readable_index"
  end

  create_table "reference_author_names", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "author_name_id", null: false
    t.integer "reference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", null: false
    t.index ["author_name_id"], name: "ix_reference_author_names__author_name_id"
    t.index ["reference_id", "position"], name: "ix_reference_author_names__reference_id__position"
    t.index ["reference_id"], name: "ix_reference_author_names__reference_id"
  end

  create_table "reference_documents", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "url"
    t.string "file_file_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reference_id"
    t.boolean "public"
    t.index ["reference_id"], name: "ux_reference_documents__reference_id", unique: true
  end

  create_table "reference_sections", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "taxon_id", null: false
    t.integer "position", null: false
    t.string "title_taxt"
    t.text "references_taxt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "subtitle_taxt"
    t.index ["taxon_id", "position"], name: "ix_reference_sections__taxon_id__position"
  end

  create_table "references", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "year", null: false
    t.string "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.integer "publisher_id"
    t.integer "journal_id"
    t.string "series_volume_issue"
    t.string "pagination", null: false
    t.text "author_names_string_cache"
    t.text "editor_notes"
    t.text "public_notes"
    t.text "taxonomic_notes"
    t.text "title", null: false
    t.integer "nesting_reference_id"
    t.string "author_names_suffix"
    t.string "review_state", default: "none", null: false
    t.text "plain_text_cache"
    t.text "expandable_reference_cache"
    t.string "doi"
    t.string "bolton_key"
    t.text "expanded_reference_cache"
    t.boolean "online_early", default: false, null: false
    t.string "stated_year"
    t.string "year_suffix", limit: 2
    t.index ["author_names_string_cache"], name: "ix_x_references__author_names_string_cache", length: 255
    t.index ["created_at"], name: "ix_references__created_at"
    t.index ["id", "type"], name: "ix_references__id__type"
    t.index ["journal_id"], name: "ix_references__journal_id"
    t.index ["nesting_reference_id"], name: "ix_references__nesting_reference_id"
    t.index ["publisher_id"], name: "ix_references__publisher_id"
    t.index ["updated_at"], name: "ix_references__updated_at"
  end

  create_table "settings", charset: "utf8", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["target_type", "target_id", "var"], name: "ux_settings__target_type__target_id__var", unique: true
    t.index ["target_type", "target_id"], name: "ix_settings__target_type__target_id"
  end

  create_table "site_notices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "title", null: false
    t.text "message", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "ix_site_notices__user_id"
  end

  create_table "taxa", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fossil", default: false, null: false
    t.string "status", null: false
    t.integer "subfamily_id"
    t.integer "tribe_id"
    t.integer "genus_id"
    t.integer "homonym_replaced_by_id"
    t.string "incertae_sedis_in"
    t.integer "species_id"
    t.integer "protonym_id", null: false
    t.integer "subgenus_id"
    t.boolean "hong", default: false, null: false
    t.integer "name_id", null: false
    t.string "name_cache", null: false
    t.boolean "unresolved_homonym", default: false, null: false
    t.integer "current_taxon_id"
    t.integer "family_id"
    t.integer "hol_id"
    t.boolean "collective_group_name", default: false, null: false
    t.boolean "original_combination", default: false, null: false
    t.integer "subspecies_id"
    t.index ["current_taxon_id"], name: "ix_taxa__current_taxon_id"
    t.index ["family_id"], name: "ix_taxa__family_id"
    t.index ["genus_id"], name: "ix_taxa__genus_id"
    t.index ["homonym_replaced_by_id"], name: "ix_taxa__homonym_replaced_by_id"
    t.index ["id", "type"], name: "ix_taxa__id__type"
    t.index ["name_cache"], name: "ix_taxa__name_cache"
    t.index ["name_id"], name: "ix_taxa__name_id"
    t.index ["protonym_id"], name: "ix_taxa__protonym_id"
    t.index ["species_id"], name: "ix_taxa__species_id"
    t.index ["status"], name: "ix_taxa__status"
    t.index ["subfamily_id"], name: "ix_taxa__subfamily_id"
    t.index ["subgenus_id"], name: "ix_taxa__subgenus_id"
    t.index ["subspecies_id"], name: "ix_taxa__subspecies_id"
    t.index ["tribe_id"], name: "ix_taxa__tribe_id"
    t.index ["type"], name: "ix_taxa__type"
  end

  create_table "tooltips", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "key", null: false
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scope", null: false
  end

  create_table "type_names", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "taxon_id", null: false
    t.integer "reference_id"
    t.string "pages"
    t.string "fixation_method"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reference_id"], name: "ix_type_names__reference_id"
    t.index ["taxon_id"], name: "ix_type_names__taxon_id"
  end

  create_table "users", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.string "password_salt", default: ""
    t.string "reset_password_token"
    t.string "remember_token"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "reset_password_sent_at"
    t.boolean "editor", default: false, null: false
    t.string "name", null: false
    t.boolean "superadmin", default: false, null: false
    t.boolean "helper", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.boolean "deleted", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.boolean "enable_email_notifications", default: true
    t.integer "author_id"
    t.boolean "developer", default: false, null: false
    t.index ["author_id"], name: "ux_users__author_id", unique: true
    t.index ["email"], name: "ux_users__email", unique: true
    t.index ["name"], name: "ux_users__name", unique: true
    t.index ["reset_password_token"], name: "ux_users__reset_password_token", unique: true
  end

  create_table "versions", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.string "request_uuid"
    t.index ["event"], name: "ix_versions__event"
    t.index ["item_id"], name: "ix_versions__item_id"
    t.index ["item_type", "item_id"], name: "ix_versions__item_type__item_id"
    t.index ["request_uuid"], name: "ix_versions__request_uuid"
    t.index ["whodunnit"], name: "ix_versions__whodunnit"
  end

  create_table "wiki_pages", charset: "utf8", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "permanent_identifier"
    t.boolean "featured", default: false, null: false
    t.index ["permanent_identifier"], name: "ux_wiki_pages__permanent_identifier", unique: true
  end

  add_foreign_key "author_names", "authors", name: "fk_author_names__author_id__authors__id"
  add_foreign_key "citations", "references", name: "fk_citations__reference_id__references__id"
  add_foreign_key "history_items", "protonyms", column: "object_protonym_id", name: "fk_history_items__object_protonym_id__protonyms__id"
  add_foreign_key "history_items", "protonyms", name: "fk_history_items__protonym_id__protonyms__id"
  add_foreign_key "history_items", "references", name: "fk_history_items__reference_id__references__id"
  add_foreign_key "history_items", "taxa", column: "object_taxon_id", name: "fk_history_items__object_taxon_id__taxa__id"
  add_foreign_key "issues", "users", column: "closer_id", name: "fk_issues__closer_id__users__id"
  add_foreign_key "issues", "users", name: "fk_issues__user_id__users__id"
  add_foreign_key "protonyms", "citations", column: "authorship_id", name: "fk_protonyms__authorship_id__citations__id"
  add_foreign_key "protonyms", "type_names", name: "fk_protonyms__type_name_id__type_names__id"
  add_foreign_key "reference_author_names", "author_names", name: "fk_reference_author_names__author_name_id__author_names__id"
  add_foreign_key "reference_author_names", "references", name: "fk_reference_author_names__reference_id__references__id"
  add_foreign_key "reference_sections", "taxa", column: "taxon_id", name: "fk_reference_sections__taxon_id__taxa__id"
  add_foreign_key "references", "journals", name: "fk_references__journal_id__journals__id"
  add_foreign_key "references", "publishers", name: "fk_references__publisher_id__publishers__id"
  add_foreign_key "site_notices", "users", name: "fk_site_notices__user_id__users__id"
  add_foreign_key "taxa", "protonyms", name: "fk_taxa__protonym_id__protonyms__id"
  add_foreign_key "taxa", "taxa", column: "current_taxon_id", name: "fk_taxa__current_taxon_id__taxa__id"
  add_foreign_key "taxa", "taxa", column: "family_id", name: "fk_taxa__family_id__taxa__id"
  add_foreign_key "taxa", "taxa", column: "genus_id", name: "fk_taxa__genus_id__taxa__id"
  add_foreign_key "taxa", "taxa", column: "homonym_replaced_by_id", name: "fk_taxa__homonym_replaced_by_id__taxa__id"
  add_foreign_key "taxa", "taxa", column: "species_id", name: "fk_taxa__species_id__taxa__id"
  add_foreign_key "taxa", "taxa", column: "subfamily_id", name: "fk_taxa__subfamily_id__taxa__id"
  add_foreign_key "taxa", "taxa", column: "subgenus_id", name: "fk_taxa__subgenus_id__taxa__id"
  add_foreign_key "taxa", "taxa", column: "subspecies_id", name: "fk_taxa__subspecies_id__taxa__id"
  add_foreign_key "taxa", "taxa", column: "tribe_id", name: "fk_taxa__tribe_id__taxa__id"
  add_foreign_key "type_names", "references", name: "fk_type_names__reference_id__references__id"
  add_foreign_key "type_names", "taxa", column: "taxon_id", name: "fk_type_names__taxon_id__taxa__id"
  add_foreign_key "users", "authors", name: "fk_users__author_id__authors__id"
end
