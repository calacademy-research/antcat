class AddExpandedReferenceCacheToReferences < ActiveRecord::Migration[5.1]
  def change
    add_column :references, :expanded_reference_cache, :text
  end
end
