# frozen_string_literal: true

class RemovePublicFromReferenceDocuments < ActiveRecord::Migration[6.1]
  def change
    remove_column :reference_documents, :public, :boolean
  end
end
