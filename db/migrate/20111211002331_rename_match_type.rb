class RenameMatchType < ActiveRecord::Migration
  def self.up
    rename_column :bolton_references, :match_type, :match_status
  end

  def self.down
    rename_column :bolton_references, :match_status, :match_type
  end
end
