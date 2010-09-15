class ReAddAuthorsString < ActiveRecord::Migration
  def self.up
    add_column :references, :authors_string, :string
  end

  def self.down
    remove_column :references, :authors_string
  end
end
