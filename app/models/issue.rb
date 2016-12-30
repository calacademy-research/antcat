# TODO completely remove the status "completed".
# The button has already been removed from the GUI and most places in the
# code, but it's still in the database (to be migrated) and some views, etc.
# Better because less complicated.

class Issue < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Trackable
  include SendsNotifications

  belongs_to :adder, class_name: "User"
  belongs_to :closer, class_name: "User"

  validates :adder, presence: true
  validates :description, presence: true, allow_blank: false
  validates :title, presence: true, allow_blank: false, length: { maximum: 70 }
  validates_inclusion_of :status, in: %w(open closed completed)

  scope :open_count, -> { where(status: "open").count }
  scope :by_status_and_date, -> { order(status: :desc, created_at: :desc) }

  acts_as_commentable
  enable_user_notifications_for :description
  has_paper_trail
  tracked on: :all, parameters: proc { { title: title } }

  def open?
    status == "open"
  end

  def archived?
    status.in? ["completed", "closed"]
  end

  def set_status status, user
    self.status = status
    self.closer = status == "open" ? nil : user
    Feed.without_tracking { save! }

    action =
      { completed: "complete_task",
        closed: "close_task",
        open: "reopen_task" }[status.to_sym]
    create_activity action
  end

  # Read-only alias for `Comment#notify_commentable_creator`.
  def user
    adder
  end
end
