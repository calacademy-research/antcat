# frozen_string_literal: true

class RenameTaxonHistoryItemsToHistoryItems < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      rename_table :taxon_history_items, :history_items
    end
  end
end
