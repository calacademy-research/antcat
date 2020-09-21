# frozen_string_literal: true

class Notification < ApplicationRecord
  REASONS = [
    'was_replied_to', # TODO: Deprecated. Remove.
    MENTIONED_IN_COMMENT = 'mentioned_in_comment',
    MENTIONED_IN_ATTACHED = 'mentioned_in_attached',
    ACTIVE_IN_DISCUSSION = 'active_in_discussion',
    CREATOR_OF_COMMENTABLE = 'creator_of_commentable'
  ]

  belongs_to :user
  belongs_to :notifier, class_name: "User"
  belongs_to :attached, polymorphic: true, optional: true # The comment, or commentable, or anything.

  validates :reason, inclusion: { in: REASONS }
  validates :attached, presence: true, on: :create

  scope :unseen, -> { where(seen: false) }
  scope :most_recent_first, -> { order(id: :desc) }

  def unseen?
    !seen?
  end
end
