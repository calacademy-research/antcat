class EditorsPanelsController < ApplicationController
  before_action :authenticate_editor

  def index
    @count = unreviewed_changes_counts
    @recent_activities = Activity.most_recent 5
    @recent_comments = Comment.most_recent 5
  end

  def invite_users
  end

  private
    # Unreviewed/pending/open/etc.
    def unreviewed_changes_counts
      {
        open_issues:                Issue.open.count,
        unreviewed_references:      Reference.unreviewed.count,
        unreviewed_catalog_changes: Change.waiting.count,
        pending_user_feedbacks:     Feedback.pending_count,
        unread_site_notices:        unread_site_notices_count,
      }
    end

    def unread_site_notices_count
      return 0 unless current_user
      SiteNotice.unread_by(current_user).count
    end
end
