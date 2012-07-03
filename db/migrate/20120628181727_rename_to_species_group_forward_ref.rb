class RenameToSpeciesGroupForwardRef < ActiveRecord::Migration
  def change
    rename_table :species_forward_refs, :species_group_forward_refs rescue nil
  end
end
