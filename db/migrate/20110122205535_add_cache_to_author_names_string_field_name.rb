class AddCacheToAuthorNamesStringFieldName < ActiveRecord::Migration
  def self.up
    rename_column :references, :author_names_string, :author_names_string_cache
  end

  def self.down
    rename_column :references, :author_names_string_cache, :author_names_string
  end
end
