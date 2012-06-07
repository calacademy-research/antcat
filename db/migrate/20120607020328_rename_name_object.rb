class RenameNameObject < ActiveRecord::Migration
  def up
    rename_column :name_objects, :name_object_name, :name
    rename_column :taxa, :name_object_id, :name_id
    rename_column :protonyms, :name_object_id, :name_id

    rename_table :name_objects, :names
  end

  def down
    rename_column :names, :name, :name_object_name
    rename_column :taxa, :name_id, :name_object_id
    rename_column :protonyms, :name_id, :name_object_id

    rename_table :names, :name_objects
  end
end
