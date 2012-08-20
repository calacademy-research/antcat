class RenameSpeciesGroupForwardRefs < ActiveRecord::Migration
  def up
    rename_table :species_group_forward_refs, :forward_refs
  end

  def down
    rename_table :forward_refs, :species_group_forward_refs
  end
end
