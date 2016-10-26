# More a helper than a proper model.
# TODO figure out how to organize this, and improve performance.

class Notification
  # Ugg, we have to keep track of `current_user` due to `SiteNotice.unread_by`.
  # TODO figure out a better method.
  def self.pending_count action, user = nil
    case action
    when :open_tasks
      open_tasks.count
    when :unreviewed_references
      unreviewed_references.count
    when :unreviewed_catalog_changes
      unreviewed_catalog_changes.count
    when :pending_user_feedbacks
      pending_user_feedbacks.count
    when :unread_site_notices
      unread_site_notices(user).count
    when :all
      all_pending_actions_count user
    end
  end

  private
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

    def self.unread_site_notices user
      SiteNotice.unread_by user
    end

    def self.all_pending_actions_count user = nil
      open_tasks.count +
      unreviewed_references.count +
      unreviewed_catalog_changes.count +
      pending_user_feedbacks.count +
      unread_site_notices(user).count
    end
end
