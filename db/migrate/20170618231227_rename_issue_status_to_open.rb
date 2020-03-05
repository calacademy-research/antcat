class RenameIssueStatusToOpen < ActiveRecord::Migration[4.2]
  def up
    add_column :issues, :open, :boolean, null: false, default: true
    remove_column :issues, :status
  end

  def down
    remove_column :issues, :open
    add_column :issues, :status, :string, default: "open"
  end
end
