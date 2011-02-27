class MakeTaxonomicHistoryLongText < ActiveRecord::Migration
  def self.up
    change_column :taxa, :taxonomic_history, :longtext
  end

  def self.down
    change_column :taxa, :taxonomic_history, :text
  end
end
