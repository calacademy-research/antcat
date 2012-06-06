class RenameNames < ActiveRecord::Migration
  def up
    rename_table :names, :name_objects
  end

  def down
    rename_table :name_objects, :names
  end
end
