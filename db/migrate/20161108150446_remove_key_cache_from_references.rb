class RemoveKeyCacheFromReferences < ActiveRecord::Migration
  def change
    remove_column :references, :key_cache
  end
end
