class Comment < ActiveRecord::Base
  include Feed::Trackable

  attr_accessor :set_parent_to

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  scope :order_by_date, -> { order(created_at: :desc)._include_associations }
  scope :most_recent, ->(number = 5) { order_by_date.limit(number) }
  scope :_include_associations, -> { includes(:commentable, :user) }

  validates :user, presence: true
  validates :body, presence: true

  after_save { set_parent if set_parent_to.present? }
  # TODO probably extract all notification logic into a class.
  after_save :notify_relevant_users

  acts_as_nested_set scope: [:commentable_id, :commentable_type]
  has_paper_trail
  tracked on: :create

  def self.build_comment commentable, user, body = ""
    new commentable: commentable, body: body, user: user
  end

  def is_a_reply?
    !parent.nil? || set_parent_to.present?
  end

  private
    def set_parent
      move_to_child_of Comment.find(set_parent_to)
    end

    # Order matters, because notified users are added to `@do_not_notify`,
    # since we only want to send one notification to each user.
    # If a user was notified because they were replied to, we're not sending
    # another three notification in case they are also the creator of the
    # commentable, active in the same discussion, and mentioned in the comment.
    def notify_relevant_users
      @do_not_notify = [user] # Never notify thyself!

      notify_replied_to_user
      notify_mentioned_users
      notify_users_in_the_same_discussion
      notify_commentable_creator
    end

    def notify_replied_to_user
      return unless is_a_reply?
      replied_to_user = parent.user
      return if do_not_notify? replied_to_user

      replied_to_user.notify_because :was_replied_to, attached: self, notifier: user
      no_more_notifications_for replied_to_user
    end

    def notify_mentioned_users
      users_mentioned_in_comment.each do |mentioned|
        unless do_not_notify? mentioned
          mentioned.notify_because :mentioned_in_comment, attached: self, notifier: User.current
          no_more_notifications_for mentioned
        end
      end
    end

    def notify_users_in_the_same_discussion
      commentable.commenters.each do |co_commenter|
        unless do_not_notify? co_commenter
          co_commenter.notify_because :active_in_discussion, attached: self, notifier: user
          no_more_notifications_for co_commenter
        end
      end
    end

    def notify_commentable_creator
      creator = commentable.try :user
      return if do_not_notify? creator
      return unless notify_creator?

      creator.notify_because :creator_of_commentable, attached: self, notifier: User.current
      no_more_notifications_for creator # Irrelevant as long as this is the last method.
    end

    def users_mentioned_in_comment
      AntcatMarkdownUtils.users_mentioned_in body
    end

    # TODO move somewhere.
    def notify_creator?
      return unless commentable.class.in? [Issue, SiteNotice, Feedback]
      return if commentable.is_a?(Feedback) && commentable.user.blank?
      true
    end

    def do_not_notify? user
      user.in? @do_not_notify
    end

    def no_more_notifications_for user
      @do_not_notify << user
    end
end
