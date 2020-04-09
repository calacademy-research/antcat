# frozen_string_literal: true

class EditorsPanelPresenter
  attr_private_initialize :current_user

  def recent_activities
    Activity.non_automated_edits.most_recent_first.limit(10).includes(:user)
  end

  def recent_comments
    Comment.most_recent_first.limit(5)
  end

  def recent_unconfirmed_activities
    Activity.unconfirmed.most_recent_first.limit(5).includes(:user)
  end

  def open_issues_count
    Issue.open.count
  end

  def unreviewed_references_count
    Reference.unreviewed.count
  end

  def pending_user_feedbacks_count
    Feedback.pending.count
  end

  def unread_site_notices_count
    current_user.unread_site_notices.count
  end
end
