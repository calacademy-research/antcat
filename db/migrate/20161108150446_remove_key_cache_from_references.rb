# Was not referenced from live code, nor kept in sync with the key.

class RemoveKeyCacheFromReferences < ActiveRecord::Migration
  def change
    remove_column :references, :key_cache
  end
end
