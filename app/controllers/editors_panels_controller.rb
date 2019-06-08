class EditorsPanelsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :invite_users

  def index
    @count = unreviewed_changes_counts
    @recent_activities = Activity.most_recent 10
    @recent_comments = Comment.most_recent 5
  end

  def invite_users
  end

  private

    def unreviewed_changes_counts
      {
        open_issues:                Issue.open.count,
        unreviewed_references:      Reference.unreviewed.count,
        unreviewed_catalog_changes: Change.waiting.count,
        pending_user_feedbacks:     Feedback.pending_count,
        unread_site_notices:        current_user&.unread_site_notices&.count
      }
    end
end
