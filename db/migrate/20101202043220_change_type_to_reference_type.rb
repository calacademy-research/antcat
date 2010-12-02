class ChangeTypeToReferenceType < ActiveRecord::Migration
  def self.up
    rename_column :bolton_references, :type, :reference_type
  end

  def self.down
    rename_column :bolton_references, :reference_type, :type
  end
end
