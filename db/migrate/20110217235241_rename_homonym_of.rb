class RenameHomonymOf < ActiveRecord::Migration
  def self.up
    rename_column :taxa, :homonym_of_id, :homonym_resolved_to_id
  end

  def self.down
    rename_column :taxa, :homonym_resolved_to_id, :homonym_of_id
  end
end
