# coding: UTF-8
class DeepSpeciesAuthorAndYear < ActiveRecord::Migration
  def self.up
    change_table :deep_species do |t|
      t.remove :genus, :species, :subspecies
      t.string :species_name
      t.string :author
      t.string :year
    end
  end

  def self.down
    change_table :deep_species do |t|
      t.string :genus
      t.string :species
      t.string :subspecies
      t.remove :species_name, :author, :year
    end
  end
end
