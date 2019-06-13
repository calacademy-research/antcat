class MoreBooleanColumnDefaultsAndNotNulls < ActiveRecord::Migration[5.2]
  def up
    change_column_null :activities, :automated_edit, false
    change_column_null :feedbacks, :open, false
  end

  def down
    change_column_null :activities, :automated_edit, true
    change_column_null :feedbacks, :open, true
  end
end
