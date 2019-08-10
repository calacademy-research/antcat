class AddHiddenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :hidden, :boolean, default: false, null: false
  end
end
