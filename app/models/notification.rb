class Notification < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  # "mentioned_in_thing" means something other than a comment. For example
  # in the description of an issue or in the message of a site notice.
  REASONS = %w( was_replied_to
                mentioned_in_comment
                mentioned_in_thing
                active_in_discussion
                creator_of_commentable )

  belongs_to :user
  belongs_to :notifier, class_name: "User"
  belongs_to :attached, polymorphic: true # The comment, or commentable, or anything.

  validates :user, presence: true
  validates :notifier, presence: true
  validates :reason, presence: true, inclusion: { in: REASONS }
  validates :attached, presence: true, on: :create

  scope :unseen, -> { where(seen: false) }
end
