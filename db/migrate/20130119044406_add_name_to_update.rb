class AddNameToUpdate < ActiveRecord::Migration
  def change
    add_column :updates, :name, :string
  end
end
