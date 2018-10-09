class AddForeignKeysToTaxa < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :taxa, :taxa, column: :subfamily_id,           name: :fk_taxa__subfamily_id__taxa__id
    add_foreign_key :taxa, :taxa, column: :tribe_id,               name: :fk_taxa__tribe_id__taxa__id
    add_foreign_key :taxa, :taxa, column: :genus_id,               name: :fk_taxa__genus_id__taxa__id
    add_foreign_key :taxa, :taxa, column: :homonym_replaced_by_id, name: :fk_taxa__homonym_replaced_by_id__taxa__id

    # TODO: Contains broken foreign keys which must be fixed.
    # add_foreign_key :taxa, :taxa, column: :species_id,             name: :fk_taxa__species_id__taxa__id
    add_foreign_key :taxa, :taxa, column: :subgenus_id,            name: :fk_taxa__subgenus_id__taxa__id
    add_foreign_key :taxa, :taxa, column: :current_valid_taxon_id, name: :fk_taxa__current_valid_taxon_id__taxa__id
    add_foreign_key :taxa, :taxa, column: :family_id,              name: :fk_taxa__family_id__taxa__id

    add_foreign_key :taxa, :protonyms, column: :protonym_id,       name: :fk_taxa__protonym_id__protonyms__id

    # Not included: `name_id`.
  end
end
