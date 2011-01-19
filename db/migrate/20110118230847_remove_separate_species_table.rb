class RemoveSeparateSpeciesTable < ActiveRecord::Migration
  def self.up
    drop_table :species
  end

  def self.down
  end
end
