# frozen_string_literal: true

class RemoveNotNullFromTaxonHistoryItemsTaxonId < ActiveRecord::Migration[6.0]
  def change
    change_column_null :taxon_history_items, :taxon_id, true
    remove_foreign_key :taxon_history_items, :taxa, column: :taxon_id,
      name: "fk_taxon_history_items__taxon_id__taxa__id"
  end
end
