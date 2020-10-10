# frozen_string_literal: true

class AddNotNullToTaxonHistoryItemsProtonymId < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      change_column_null :taxon_history_items, :protonym_id, false
    end
  end
end
