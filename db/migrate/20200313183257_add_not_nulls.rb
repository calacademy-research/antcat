class AddNotNulls < ActiveRecord::Migration[6.0]
  def change
    change_column_null :activities, :action, false
    change_column_null :comments, :body, false
    change_column_null :issues, :adder_id, false
    change_column_null :references, :title, false
  end
end
