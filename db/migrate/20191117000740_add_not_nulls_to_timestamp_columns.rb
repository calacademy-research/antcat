class AddNotNullsToTimestampColumns < ActiveRecord::Migration[5.2]
  def change
    change_column_null :activities, :created_at, false
    change_column_null :author_names, :created_at, false
    change_column_null :authors, :created_at, false
    change_column_null :citations, :created_at, false
    change_column_null :comments, :created_at, false
    change_column_null :feedbacks, :created_at, false
    change_column_null :journals, :created_at, false
    change_column_null :names, :created_at, false
    change_column_null :protonyms, :created_at, false
    change_column_null :publishers, :created_at, false
    change_column_null :reference_author_names, :created_at, false
    change_column_null :reference_documents, :created_at, false
    change_column_null :reference_sections, :created_at, false
    change_column_null :references, :created_at, false
    change_column_null :taxa, :created_at, false
    change_column_null :taxon_history_items, :created_at, false
    change_column_null :tooltips, :created_at, false
    change_column_null :users, :created_at, false

    change_column_null :activities, :updated_at, false
    change_column_null :author_names, :updated_at, false
    change_column_null :authors, :updated_at, false
    change_column_null :citations, :updated_at, false
    change_column_null :comments, :updated_at, false
    change_column_null :feedbacks, :updated_at, false
    change_column_null :journals, :updated_at, false
    change_column_null :names, :updated_at, false
    change_column_null :protonyms, :updated_at, false
    change_column_null :publishers, :updated_at, false
    change_column_null :reference_author_names, :updated_at, false
    change_column_null :reference_documents, :updated_at, false
    change_column_null :reference_sections, :updated_at, false
    change_column_null :references, :updated_at, false
    change_column_null :taxa, :updated_at, false
    change_column_null :taxon_history_items, :updated_at, false
    change_column_null :tooltips, :updated_at, false
    change_column_null :users, :updated_at, false
  end
end
