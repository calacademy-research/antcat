class RenameDocumentsToReferenceDocuments < ActiveRecord::Migration
  def self.up
    rename_table :documents, :reference_documents
  end

  def self.down
    rename_table :reference_documents, :documents
  end
end
