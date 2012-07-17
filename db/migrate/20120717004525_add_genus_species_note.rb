class AddGenusSpeciesNote < ActiveRecord::Migration
  def change
    add_column :taxa, :genus_species_header_note, :text
  end
end
