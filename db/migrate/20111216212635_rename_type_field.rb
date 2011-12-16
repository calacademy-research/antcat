class RenameTypeField < ActiveRecord::Migration
  def self.up
    rename_column :taxa, :type_field_id, :type_taxon_id
  end

  def self.down
    rename_column :taxa, :type_taxon_id, :type_field_id
  end
end
