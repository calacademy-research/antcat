# frozen_string_literal: true

class Notification < ApplicationRecord
  # "mentioned_in_thing" means something other than a comment. For example
  # in the description of an issue or in the message of a site notice.
  # TODO: Rename `mentioned_in_thing` --> `mentioned_in_attached`.
  REASONS = [
    'was_replied_to', # TODO: Deprecated. Remove.
    MENTIONED_IN_COMMENT = 'mentioned_in_comment',
    MENTIONED_IN_THING = 'mentioned_in_thing',
    ACTIVE_IN_DISCUSSION = 'active_in_discussion',
    CREATOR_OF_COMMENTABLE = 'creator_of_commentable'
  ]

  belongs_to :user
  belongs_to :notifier, class_name: "User"
  belongs_to :attached, polymorphic: true # The comment, or commentable, or anything.

  validates :user, presence: true
  validates :notifier, presence: true
  validates :reason, presence: true, inclusion: { in: REASONS }
  validates :attached, presence: true, on: :create

  scope :unseen, -> { where(seen: false) }
end
