class RemoveUnusedColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :taxa, :genus_species_header_notes_taxt, :text
    remove_column :taxa, :display, :boolean, default: true
    remove_column :references, :principal_author_last_name_cache, :string
    remove_column :names, :protonym_html, :string
  end
end
