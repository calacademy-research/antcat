class AddDateIndexes < ActiveRecord::Migration
  def self.up
    add_index :references, :created_at, :name => 'references_created_at_idx'
    add_index :references, :updated_at, :name => 'references_updated_at_idx'
  end

  def self.down
    remove_index :references, :name => 'references_updated_at_idx'
    remove_index :references, :name => 'references_created_at_idx'
  end
end
