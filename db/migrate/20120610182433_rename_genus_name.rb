class RenameGenusName < ActiveRecord::Migration
  def up
    rename_column :names, :genus_name_id, :genus_group_name_id
  end

  def down
    rename_column :names, :genus_group_name_id, :genus_name_id
  end
end
