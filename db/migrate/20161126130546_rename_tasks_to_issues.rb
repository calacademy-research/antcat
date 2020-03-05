class RenameTasksToIssues < ActiveRecord::Migration[4.2]
  def change
    rename_table :tasks, :issues
  end
end
