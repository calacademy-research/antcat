# frozen_string_literal: true

# Where the words in `etymology_taxt` come from (Brian Fisher, 13 Nov 2026): the etymology field holds the
# author's words exactly as printed; these columns say whose words and where they were printed, give an
# English translation when the original is not English, and keep AntCat's own reading separate.
class AddEtymologySourceToProtonyms < ActiveRecord::Migration[8.1]
  def change
    change_table :protonyms, bulk: true do |t|
      t.string :etymology_source
      t.integer :etymology_reference_id
      t.string :etymology_pages
      t.text :etymology_translation
      t.text :etymology_derivation
    end
    add_index :protonyms, :etymology_reference_id, name: "ix_protonyms__etymology_reference_id"
    add_foreign_key :protonyms, :references, column: :etymology_reference_id,
      name: "fk_protonyms__etymology_reference_id__references__id"
  end
end
