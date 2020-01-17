class AddHelpWantedToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :help_wanted, :boolean, null: false, default: false
  end
end
