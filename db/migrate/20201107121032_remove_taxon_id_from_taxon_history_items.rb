# frozen_string_literal: true

class RemoveTaxonIdFromTaxonHistoryItems < ActiveRecord::Migration[6.0]
  def change
    remove_column :taxon_history_items, :taxon_id, :integer
  end
end
