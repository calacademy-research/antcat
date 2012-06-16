class RemoveTaxonomicHistoryColumn < ActiveRecord::Migration
  def up
    remove_column :taxa, :taxonomic_history
  end

  def down
    add_column :taxa, :taxonomic_history, :string
  end
end
