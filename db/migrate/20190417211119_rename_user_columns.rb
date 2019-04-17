class RenameUserColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :is_superadmin, :superadmin
    rename_column :users, :can_edit, :editor
    rename_column :users, :is_helper, :helper
  end
end
