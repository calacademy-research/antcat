class RemoveAuthorsString < ActiveRecord::Migration
  def self.up
    remove_column :references, :authors_string
  end

  def self.down
    add_column :references, :authors_string
  end
end
