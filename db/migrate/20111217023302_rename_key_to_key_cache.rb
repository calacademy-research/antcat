class RenameKeyToKeyCache < ActiveRecord::Migration
  def self.up
    rename_column :bolton_references, :key, :key_cache
  end

  def self.down
    rename_column :bolton_references, :key_cache, :key
  end
end
