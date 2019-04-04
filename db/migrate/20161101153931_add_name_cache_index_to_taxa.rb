class AddNameCacheIndexToTaxa < ActiveRecord::Migration
  def change
    add_index :taxa, :name_cache
  end
end
