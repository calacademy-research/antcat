class AddSpeciesId < ActiveRecord::Migration
  def self.up
    add_column :taxa, :species_id, :integer
  end

  def self.down
    remove_column :taxa, :species_id
  end
end
