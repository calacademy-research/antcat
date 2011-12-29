class AddPositionToTaxonomicHistoryItem < ActiveRecord::Migration
  def change
    add_column :taxonomic_history_items, :position, :integer
  end
end
