class RenameGenusSpeciesHeaderNote < ActiveRecord::Migration
  def up
    rename_column :taxa, :genus_species_header_note, :genus_species_header_notes_taxt
  end

  def down
    rename_column :taxa, :genus_species_header_notes_taxt, :genus_species_header_note
  end
end
