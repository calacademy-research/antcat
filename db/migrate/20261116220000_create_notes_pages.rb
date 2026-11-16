# frozen_string_literal: true

# One page of notes per protonym ("Notes on this name"; Brian Fisher, 16 Nov 2026): the background a name needs
# beyond its short public notes, written in Markdown, with sections as needed (Etymological notes, Type specimen
# notes, Nomenclatural notes). Its own table and not a wiki page: the wiki holds the site's help pages, and
# hundreds of pages about names would bury them.
class CreateNotesPages < ActiveRecord::Migration[8.1]
  def change
    create_table :notes_pages, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t|
      t.integer :protonym_id, null: false
      t.text :content, size: :medium, null: false
      t.timestamps
    end
    add_index :notes_pages, :protonym_id, unique: true, name: "ux_notes_pages__protonym_id"
    add_foreign_key :notes_pages, :protonyms, name: "fk_notes_pages__protonym_id__protonyms__id"
  end
end
