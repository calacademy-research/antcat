# More a helper than a proper model.
# TODO figure out how to organize this, and improve performance.
# See the git log for `.all_pending_actions_count` code that was
# removed for performance reasons.

class Notification
  def self.open_tasks
    Task.open
  end

  def self.unreviewed_references
    Reference.where.not(review_state: "reviewed")
  end

  def self.unreviewed_catalog_changes
    Change.waiting
  end

  def self.pending_user_feedbacks
    Feedback.where(open: true)
  end

  def self.unread_site_notices user = nil
    return SiteNotice.none unless user
    SiteNotice.unread_by user
  end
end
