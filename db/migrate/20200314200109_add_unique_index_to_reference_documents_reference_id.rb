# frozen_string_literal: true

class AddUniqueIndexToReferenceDocumentsReferenceId < ActiveRecord::Migration[6.0]
  def change
    add_index :reference_documents, :reference_id, unique: true
  end
end
