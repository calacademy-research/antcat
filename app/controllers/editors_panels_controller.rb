class EditorsPanelsController < ApplicationController
  before_action :authenticate_editor

  def index
    @count = {
      open_tasks: Notification.open_tasks.count,
      unreviewed_references: Notification.unreviewed_references.count,
      unreviewed_catalog_changes: Notification.unreviewed_catalog_changes.count,
      pending_user_feedbacks: Notification.pending_user_feedbacks.count,
      unread_site_notices: Notification.unread_site_notices(current_user).count,
    }

    @recent_activities = Feed::Activity.most_recent 5
    @recent_comments = Comment.most_recent 5
  end
end
