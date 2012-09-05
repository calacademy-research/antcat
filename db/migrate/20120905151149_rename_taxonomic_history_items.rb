class RenameTaxonomicHistoryItems < ActiveRecord::Migration
  def up
    rename_table :taxonomic_history_items, :taxon_history_items
  end

  def down
    rename_table :taxon_history_items, :taxonomic_history_items
  end
end
