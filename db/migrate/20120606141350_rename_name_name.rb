class RenameNameName < ActiveRecord::Migration
  def up
    rename_column :names, :name, :name_object_name
  end

  def down
    rename_column :names, :name_object_name, :name
  end
end
