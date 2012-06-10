class RemoveProtonymRank < ActiveRecord::Migration
  def up
    remove_column :protonyms, :rank
  end

  def down
    add_column :protonyms, :rank, :string
  end
end
