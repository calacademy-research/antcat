class RenameDocumentFile < ActiveRecord::Migration
  def self.up
    rename_table :document_files, :documents
  end

  def self.down
    rename_table :documents, :document_files
  end
end
