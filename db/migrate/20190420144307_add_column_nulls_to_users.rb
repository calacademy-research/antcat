class AddColumnNullsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :superadmin, false
    change_column_null :users, :editor, false
  end
end
