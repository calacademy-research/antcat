# frozen_string_literal: true

module Comments
  class NotifyRelevantUsers
    include Service

    def initialize comment
      @comment = comment
    end

    # Order matters, since we only want to send one notification to each user.
    # If a user was notified because they were mentioned in the comment, we're not sending
    # another three notification in case they are also the creator of the
    # commentable and active in the same discussion.
    def call
      notify_mentioned_users
      notify_users_in_the_same_discussion
      notify_commentable_creator
    end

    private

      attr_accessor :comment

      delegate :commentable, :body, to: :comment

      def notify_mentioned_users
        users_mentioned_in_comment.each do |mentioned_user|
          notify mentioned_user, Notification::MENTIONED_IN_COMMENT
        end
      end

      def users_mentioned_in_comment
        Markdowns::MentionedUsers[body]
      end

      def notify_users_in_the_same_discussion
        commentable.commenters.each do |co_commenter|
          notify co_commenter, Notification::ACTIVE_IN_DISCUSSION
        end
      end

      def notify_commentable_creator
        return unless notify_creator?

        creator = commentable.try :user
        notify creator, :creator_of_commentable
      end

      # TODO: Improve and move somewhere.
      def notify_creator?
        # These are the only models for which we want to notify the creator about.
        return false unless commentable.class.in? [Issue, SiteNotice, Feedback]

        # Unregistered users can submit feedback, but we only want to
        # notify submitters who are registered users.
        return false if commentable.is_a?(Feedback) && commentable.user.blank?
        true
      end

      def notify user, reason
        Users::Notify[user, reason, attached: comment, notifier: comment.user]
      end
  end
end
