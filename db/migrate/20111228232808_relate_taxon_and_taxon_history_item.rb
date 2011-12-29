class RelateTaxonAndTaxonHistoryItem < ActiveRecord::Migration
  def up
    add_column :taxonomic_history_items, :taxon_id, :integer
  end

  def down
    remove_column :taxonomic_history_items, :taxon_id
  end
end
