# frozen_string_literal: true

class AddForeignKeyToReferenceDocumentsReferenceId < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :reference_documents, :references, name: :fk_reference_documents__reference_id__references__id
  end
end
