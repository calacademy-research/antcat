class AddUserToChanges < ActiveRecord::Migration
  def change
    add_column :changes, :user_id, :integer
  end
end
