class RenameGeneraToAntwebTaxonomy < ActiveRecord::Migration
  def self.up
    rename_table :genera, :antweb_taxonomy
  end

  def self.down
    rename_table :antweb_taxonomy, :genera
  end
end
