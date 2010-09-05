class RenameReferencesToWardReferences < ActiveRecord::Migration
  def self.up
    rename_table :refs, :ward_references
    rename_table :bolton_refs, :bolton_references
    rename_column :bolton_references, :ward_id, :ward_reference_id
  end

  def self.down
    rename_table :bolton_references, :bolton_refs 
    rename_table :ward_references, :refs 
    rename_column :bolton_refs, :ward_reference_id, :ward_id
  end
end
