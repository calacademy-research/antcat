# TODO: Remove blanked data migrations like this one.
# Was not handled in `RenameTasksToIssues`.

class UpdateIssueReferences < ActiveRecord::Migration[4.2]
  def up
   # PaperTrail::Version.where(item_type: "Task").update_all item_type: "Issue"
   # Activity.where(trackable_type: "Task").update_all trackable_type: "Issue"
   # Comment.where(commentable_type: "Task").update_all commentable_type: "Issue"
  end

  def down
    # PaperTrail::Version.where(item_type: "Issue").update_all item_type: "Task"
    # Activity.where(trackable_type: "Issue").update_all trackable_type: "Task"
    # Comment.where(commentable_type: "Issue").update_all commentable_type: "Task"
  end
end
