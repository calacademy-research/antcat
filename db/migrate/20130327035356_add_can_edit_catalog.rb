class AddCanEditCatalog < ActiveRecord::Migration
  def up
    add_column :users, :can_edit_catalog, :boolean
  end

  def down
    remove_column :users, :can_edit_catalog
  end
end
