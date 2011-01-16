class CreateDocumentsIndex < ActiveRecord::Migration
  def self.up
    add_index :documents, :reference_id, :name => 'documents_reference_id_idx'
  end

  def self.down
    remove_index :documents, :name => 'documents_reference_id_idx'
  end
end
