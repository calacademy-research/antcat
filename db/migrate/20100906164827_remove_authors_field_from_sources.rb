class RemoveAuthorsFieldFromSources < ActiveRecord::Migration
  def self.up
    remove_column :sources, :authors
  end

  def self.down
    add_column :sources, :authors, :string
  end
end
