class ReferenceHasOneDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :reference_id, :integer
    remove_column :references, :document_id
  end

  def self.down
    add_column :references, :document_id, :integer
    remove_column :documents, :reference_id
  end
end
