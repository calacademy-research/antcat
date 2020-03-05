class AddUserToChanges < ActiveRecord::Migration[4.2]
  def change
    add_column :changes, :user_id, :integer
  end
end
