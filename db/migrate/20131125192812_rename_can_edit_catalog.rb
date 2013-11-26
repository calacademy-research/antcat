class RenameCanEditCatalog < ActiveRecord::Migration
  def up
    rename_column :users, :can_edit_catalog, :can_edit
  end

  def down
    rename_column :users, :can_edit, :can_edit_catalog
  end
end
