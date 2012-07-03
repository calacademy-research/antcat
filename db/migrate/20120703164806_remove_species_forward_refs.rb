class RemoveSpeciesForwardRefs < ActiveRecord::Migration
  def change
    drop_table :species_forward_refs rescue nil
  end
end
