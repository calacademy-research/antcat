class RemoveDeepSpecies < ActiveRecord::Migration
  def self.up
    drop_table :deep_species
  end

  def self.down
    raise IrreversibleMigration
  end
end
