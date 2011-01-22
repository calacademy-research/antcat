class AddCacheToPrincipalAuthorLastNamesFieldName < ActiveRecord::Migration
  def self.up
    rename_column :references, :principal_author_last_name, :principal_author_last_name_cache
  end

  def self.down
    rename_column :references, :principal_author_last_name_cache, :principal_author_last_name
  end
end
