# frozen_string_literal: true

class AddNotNullToReferenceDocumentsReferenceId < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_column_null :reference_documents, :reference_id, false
    end
  end
end
