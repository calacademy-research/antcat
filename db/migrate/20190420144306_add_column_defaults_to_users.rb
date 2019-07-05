class AddColumnDefaultsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :superadmin, from: nil, to: false
    change_column_default :users, :editor, from: nil, to: false
  end
end
