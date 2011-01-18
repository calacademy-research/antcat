class MakeTaxonSti < ActiveRecord::Migration
  def self.up
    rename_column :taxa, :rank, :type
  end

  def self.down
    rename_column :taxa, :type, :rank
  end
end
