class RemoveProtonymName < ActiveRecord::Migration
  def up
    remove_column :protonyms, :name
  end

  def down
    add_column :protonyms, :name
  end
end
