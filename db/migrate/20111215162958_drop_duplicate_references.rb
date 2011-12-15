class DropDuplicateReferences < ActiveRecord::Migration
  def self.up
    drop_table :duplicate_references
  end

  def self.down
    raise IrreversibleMigration
  end
end
