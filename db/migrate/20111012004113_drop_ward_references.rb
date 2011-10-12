class DropWardReferences < ActiveRecord::Migration
  def self.up
    drop_table :ward_references
  end

  def self.down
    raise IrreversibleMigration
  end
end
