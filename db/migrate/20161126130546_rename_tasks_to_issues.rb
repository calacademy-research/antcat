class RenameTasksToIssues < ActiveRecord::Migration
  def change
    rename_table :tasks, :issues
  end
end
