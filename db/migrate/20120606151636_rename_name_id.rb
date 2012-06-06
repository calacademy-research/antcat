class RenameNameId < ActiveRecord::Migration
  def up
    rename_column :taxa, :name_id, :name_object_id
    rename_column :protonyms, :name_id, :name_object_id
  end

  def down
    rename_column :protonyms, :name_object_id, :name_id
    rename_column :taxa, :name_object_id, :name_id
  end
end
