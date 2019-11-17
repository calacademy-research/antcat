class AddNotNullsPart2 < ActiveRecord::Migration[5.2]
  def change
    change_column_null :author_names, :author_id, false
    change_column_null :author_names, :name, false
    change_column_null :journals, :name, false
    change_column_null :reference_author_names, :position, false
    change_column_null :reference_sections, :position, false
    change_column_null :reference_sections, :taxon_id, false
    change_column_null :taxa, :protonym_id, false
    change_column_null :taxa, :status, false
    change_column_null :taxa, :type, false
    change_column_null :taxon_history_items, :position, false
    change_column_null :taxon_history_items, :taxon_id, false
    change_column_null :users, :name, false
  end
end
