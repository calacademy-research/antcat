class AddCreateAtNameIndexToAuthors < ActiveRecord::Migration
  def self.up
    add_index :authors, [:created_at, :name], :name => 'author_created_at_name'
  end

  def self.down
    remove_index :authors, :name => 'author_created_at_name'
  end
end
