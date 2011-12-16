class RenameReferenceLocationToCitation < ActiveRecord::Migration
  def self.up
    rename_table :reference_locations, :citations
  end

  def self.down
    rename_table :citations, :reference_locations
  end
end
