class AddEditedToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :edited, :boolean, default: false, null: false
  end
end
