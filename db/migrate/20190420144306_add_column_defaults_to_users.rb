class AddColumnDefaultsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :superadmin, false
    change_column_default :users, :editor, false
  end
end
