class EditorsPanelsController < ApplicationController
  before_action :authenticate_editor

  def index
    @count = {
      open_tasks: Notification.pending_count(:open_tasks),
      unreviewed_references: Notification.pending_count(:unreviewed_references),
      unreviewed_catalog_changes: Notification.pending_count(:unreviewed_catalog_changes),
      pending_user_feedbacks: Notification.pending_count(:pending_user_feedbacks),
      unread_site_notices: Notification.pending_count(:unread_site_notices, current_user),
    }

    @recent_activities = Feed::Activity.most_recent 5
    @recent_comments = Comment.most_recent 5
  end
end
