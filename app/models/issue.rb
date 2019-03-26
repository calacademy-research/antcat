class Issue < ApplicationRecord
  include RevisionsCanBeCompared
  include Trackable
  include SendsNotifications

  belongs_to :adder, class_name: "User"
  belongs_to :closer, class_name: "User"

  validates :adder, presence: true
  validates :description, presence: true
  validates :title, presence: true, length: { maximum: 70 }

  scope :open, -> { where(open: true) }
  scope :by_status_and_date, -> { order(open: :desc, created_at: :desc) }

  acts_as_commentable
  enable_user_notifications_for :description
  has_paper_trail
  tracked on: :mixin_create_activity_only, parameters: proc { { title: title } }

  def closed?
    !open?
  end

  def close! user
    update! open: false, closer: user
  end

  def reopen!
    update! open: true, closer: nil
  end

  # Read-only alias for `Comment#notify_commentable_creator`.
  def user
    adder
  end
end
