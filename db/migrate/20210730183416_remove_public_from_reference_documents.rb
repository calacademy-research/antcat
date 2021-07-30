# frozen_string_literal: true

class RemovePublicFromReferenceDocuments < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :reference_documents, :public, :boolean
    end
  end
end
