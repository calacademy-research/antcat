# Continue to remove threading. elight/acts_as_commentable_with_threading
# has been deprecated, and we don't really need it anyways.
# TODO: Migrate data.
# TODO: Replace gem or just re-implement the basics.

class Comment < ApplicationRecord
  include Trackable

  BODY_MAX_LENGTH = 100_000

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :user, :body, presence: true
  validates :body, length: { maximum: BODY_MAX_LENGTH }

  scope :order_by_date, -> { order(created_at: :desc) }
  scope :most_recent, ->(number = 5) { order_by_date.include_associations.limit(number) }
  scope :include_associations, -> { includes(:commentable, :user) }

  acts_as_nested_set scope: [:commentable_id, :commentable_type]
  alias_method :commenter, :user # Read-only, for `Comments::NotifyRelevantUsers`.
  has_paper_trail
  trackable

  def self.build_comment commentable, user, body: nil
    new(commentable: commentable, body: body, user: user)
  end

  def notify_relevant_users
    Comments::NotifyRelevantUsers[self]
  end
end
