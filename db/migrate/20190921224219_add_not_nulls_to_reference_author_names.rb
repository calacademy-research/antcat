class AddNotNullsToReferenceAuthorNames < ActiveRecord::Migration[5.2]
  def change
    change_column_null :reference_author_names, :author_name_id, false
    change_column_null :reference_author_names, :reference_id, false
  end
end
