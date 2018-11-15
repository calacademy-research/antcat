class AddIsHelperToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_helper, :boolean, default: false, null: false
  end
end
