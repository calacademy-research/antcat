class RenameIssueStatusToOpen < ActiveRecord::Migration
  def up
    add_column :issues, :open, :boolean, null: false, default: true

    Issue.where(status: "open").update_all(open: true)
    Issue.where(status: ["closed", "completed"]).update_all(open: false)

    activities = Activity.where(trackable_type: "Issue")
    activities.where(action: "complete_task").update_all(action: "close_issue")
    activities.where(action: "close_task").update_all(action: "close_issue")

    remove_column :issues, :status
  end

  # Sets all issues to open; we can take care of this later if we ever need to.
  def down
    remove_column :issues, :open
    add_column :issues, :status, :string, default: "open"
  end
end
