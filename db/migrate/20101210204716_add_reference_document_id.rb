class AddReferenceDocumentId < ActiveRecord::Migration
  def self.up
    add_column :references, :document_id, :integer
  end

  def self.down
    remove_column :references, :document_id
  end
end
