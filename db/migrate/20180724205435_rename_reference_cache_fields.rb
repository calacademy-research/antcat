class RenameReferenceCacheFields < ActiveRecord::Migration[5.1]
  def change
    rename_column :references, :formatted_cache, :plain_text_cache
    rename_column :references, :inline_citation_cache, :expandable_reference_cache
  end
end
