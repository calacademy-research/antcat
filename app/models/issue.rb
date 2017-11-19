class Issue < ActiveRecord::Base
  include Trackable
  include SendsNotifications

  belongs_to :adder, class_name: "User"
  belongs_to :closer, class_name: "User"

  validates :adder, presence: true
  validates :description, presence: true, allow_blank: false
  validates :title, presence: true, allow_blank: false, length: { maximum: 70 }

  scope :open, -> { where(open: true) }
  scope :by_status_and_date, -> { order(open: :desc, created_at: :desc) }

  acts_as_commentable
  enable_user_notifications_for :description
  has_paper_trail
  tracked on: :all, parameters: proc { { title: title } }

  def closed?
    !open?
  end

  def close! user
    Feed.without_tracking { update! open: false, closer: user }
    create_activity :close_issue
  end

  def reopen!
    Feed.without_tracking { update! open: true, closer: nil }
    create_activity :reopen_issue
  end

  # Read-only alias for `Comment#notify_commentable_creator`.
  def user
    adder
  end
end
