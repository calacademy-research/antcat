# coding: UTF-8
class AddDeepSpecies < ActiveRecord::Migration
  def self.up
    create_table :deep_species do |t|
      t.string  :name
      t.string  :genus
      t.string  :species
      t.string  :subspecies
    end
  end

  def self.down
    drop_table :deep_species
  end
end
