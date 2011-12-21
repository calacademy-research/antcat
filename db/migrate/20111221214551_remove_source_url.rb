class RemoveSourceUrl < ActiveRecord::Migration
  def self.up
    remove_column :references, :source_url
    remove_column :references, :source_file_name
  end

  def self.down
    add_column :references, :source_url, :string
    add_column :references, :source_file_name, :string
  end
end
