class EditorsPanelsController < ApplicationController
  def index
    @count = {
      open_tasks: Notification.pending_count(:open_tasks),
      unreviewed_references: Notification.pending_count(:unreviewed_references),
      unreviewed_catalog_changes: Notification.pending_count(:unreviewed_catalog_changes),
      pending_user_feedbacks: Notification.pending_count(:pending_user_feedbacks),
    }
  end
end
