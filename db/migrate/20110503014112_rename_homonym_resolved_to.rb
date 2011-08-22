# coding: UTF-8
class RenameHomonymResolvedTo < ActiveRecord::Migration
  def self.up
    rename_column :taxa, :homonym_resolved_to_id, :homonym_replaced_by_id
    rename_index :taxa, :taxa_homonym_resolved_to_id_index, :taxa_homonym_replaced_by_id_index
  end

  def self.down
    rename_index :taxa, :taxa_homonym_replaced_by_id_index, :taxa_homonym_resolved_to_id_index
    rename_column :taxa, :homonym_replaced_by_id, :homonym_resolved_to_id
  end
end
