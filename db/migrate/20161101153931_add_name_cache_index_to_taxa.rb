class AddNameCacheIndexToTaxa < ActiveRecord::Migration[4.2]
  def change
    add_index :taxa, :name_cache
  end
end
