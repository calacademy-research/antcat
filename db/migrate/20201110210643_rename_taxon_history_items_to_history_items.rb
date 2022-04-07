# frozen_string_literal: true

class RenameTaxonHistoryItemsToHistoryItems < ActiveRecord::Migration[6.0]
  def change
    rename_table :taxon_history_items, :history_items
  end
end
