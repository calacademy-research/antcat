class ChangeBooksToSources < ActiveRecord::Migration
  def self.up
    rename_table :books, :sources
    add_column :sources, :type, :string
  end

  def self.down
    remove_column :sources, :type
    rename_table :sources, :books
  end
end
