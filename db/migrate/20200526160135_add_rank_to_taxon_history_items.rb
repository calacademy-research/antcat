# frozen_string_literal: true

class AddRankToTaxonHistoryItems < ActiveRecord::Migration[6.0]
  def change
    add_column :taxon_history_items, :rank, :string
  end
end
