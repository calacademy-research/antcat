class AddNotNulls < ActiveRecord::Migration[5.2]
  def change
    change_column_null :citations, :pages, false
    change_column_null :citations, :reference_id, false
    change_column_null :feedbacks, :comment, false
    change_column_null :issues, :description, false
    change_column_null :issues, :title, false
    change_column_null :protonyms, :authorship_id, false
    change_column_null :publishers, :name, false
    change_column_null :publishers, :place_name, false
    change_column_null :site_notices, :message, false
    change_column_null :site_notices, :title, false
    change_column_null :site_notices, :user_id, false
    change_column_null :taxon_history_items, :taxt, false
    change_column_null :tooltips, :key, false
    change_column_null :tooltips, :scope, false
    change_column_null :tooltips, :text, false
  end
end
