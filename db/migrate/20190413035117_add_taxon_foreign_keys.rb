class AddTaxonForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :taxon_history_items, :taxa, column: :taxon_id, name: :fk_taxon_history_items__taxon_id__taxa__id
    add_foreign_key :reference_sections,  :taxa, column: :taxon_id, name: :fk_reference_sections__taxon_id__taxa__id
  end
end
