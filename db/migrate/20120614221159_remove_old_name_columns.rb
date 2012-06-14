class RemoveOldNameColumns < ActiveRecord::Migration
  def up
    remove_column :names, :genus_group_name_id
    remove_column :names, :species_name_id
    remove_column :names, :subspecies_qualifier
    remove_column :names, :next_subspecies_name_id
    remove_column :names, :prior_subspecies_name_id
  end

  def down
    add_column :names, :prior_subspecies_name_id, :integer
    add_column :names, :next_subspecies_name_id, :integer
    add_column :names, :subspecies_qualifier, :integer
    add_column :names, :species_name_id, :integer
    add_column :names, :genus_group_name_id, :integer
  end
end
