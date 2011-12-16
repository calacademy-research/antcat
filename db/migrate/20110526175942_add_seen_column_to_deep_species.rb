# coding: UTF-8
class AddSeenColumnToDeepSpecies < ActiveRecord::Migration
  def self.up
    add_column :deep_species, :seen, :boolean
  end

  def self.down
    remove_column :deep_species, :seen
  end
end
