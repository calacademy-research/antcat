# frozen_string_literal: true

module Comments
  class NotifyRelevantUsers
    include Service

    attr_private_initialize :comment

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
        return unless (creator = commentable.user)
        notify creator, Notification::CREATOR_OF_COMMENTABLE
      end

      def notify user, reason
        Users::Notify[user, reason, attached: comment, notifier: comment.user]
      end
  end
end
