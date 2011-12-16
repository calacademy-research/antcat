class RenameAuthorYearKey < ActiveRecord::Migration
  def self.up
    rename_column :bolton_references, :author_year_key, :key
    rename_column :references, :bolton_author_year_key, :bolton_key_cache
  end

  def self.down
    rename_column :references, :bolton_key_cache, :bolton_author_year_key
    rename_column :bolton_references, :key, :author_year_key
  end
end
