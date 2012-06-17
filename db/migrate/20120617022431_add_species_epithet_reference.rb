class AddSpeciesEpithetReference < ActiveRecord::Migration
  def up
    add_column :forward_references, :type, :string
    add_column :forward_references, :fixee_table, :string
    add_column :forward_references, :genus_id, :integer
    add_column :forward_references, :epithet, :string
  end

  def down
    remove_column :forward_references, :epithet
    remove_column :forward_references, :genus_id
    remove_column :forward_references, :fixee_table
    remove_column :forward_references, :type
  end
end
