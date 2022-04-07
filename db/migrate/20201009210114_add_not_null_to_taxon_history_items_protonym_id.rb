# frozen_string_literal: true

class AddNotNullToTaxonHistoryItemsProtonymId < ActiveRecord::Migration[6.0]
  def change
    change_column_null :taxon_history_items, :protonym_id, false
  end
end
