# More a helper than a proper model.
# TODO figure out how to organize this.

class Notification
  def self.pending_count action
    case action
    when :open_tasks
      open_tasks.count
    when :unreviewed_references
      unreviewed_references.count
    when :unreviewed_catalog_changes
      unreviewed_catalog_changes.count
    when :all
      all_pending_actions_count
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

    def self.all_pending_actions_count
      open_tasks.count +
      unreviewed_references.count +
      unreviewed_catalog_changes.count
    end
end