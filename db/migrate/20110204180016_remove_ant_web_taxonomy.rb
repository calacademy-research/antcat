class RemoveAntWebTaxonomy < ActiveRecord::Migration
  def self.up
    drop_table :antweb_taxonomy
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
