class AddLocality < ActiveRecord::Migration
  def up
    add_column :protonyms, :locality, :string
  end

  def down
    remove_column :protonyms, :locality
  end
end
