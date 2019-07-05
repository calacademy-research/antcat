# Follow up to `AddForeignKeysToTaxa`.

class AddSpeciesIdForeignKeyToTaxa < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :taxa, :taxa, column: :species_id, name: :fk_taxa__species_id__taxa__id
  end
end
