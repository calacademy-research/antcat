module Comments
  class NotifyRelevantUsers
    include Service

    def initialize comment
      @comment = comment
      @do_not_notify = [comment.user] # Never notify thyself!
    end

    # Order matters, because notified users are added to `@do_not_notify`,
    # since we only want to send one notification to each user.
    # If a user was notified because they were mentioned in the comment, we're not sending
    # another three notification in case they are also the creator of the
    # commentable and active in the same discussion.
    def call
      notify_mentioned_users
      notify_users_in_the_same_discussion
      notify_commentable_creator
    end

    private

      attr_accessor :comment, :do_not_notify

      delegate :commentable, :body, to: :comment

      def notify_mentioned_users
        users_mentioned_in_comment.each do |mentioned_user|
          notify mentioned_user, :mentioned_in_comment
        end
      end

      def notify_users_in_the_same_discussion
        commentable.commenters.each do |co_commenter|
          notify co_commenter, :active_in_discussion
        end
      end

      def notify_commentable_creator
        return unless notify_creator?

        creator = commentable.try :user
        notify creator, :creator_of_commentable
      end

      def users_mentioned_in_comment
        Markdowns::MentionedUsers[body]
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
        return if user.in? do_not_notify

        user.notify_because reason, attached: comment, notifier: comment.user
        do_not_notify << user
      end
  end
end
