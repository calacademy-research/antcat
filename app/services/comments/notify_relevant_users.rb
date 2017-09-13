module Comments
  class NotifyRelevantUsers
    def initialize comment
      @comment = comment
      @do_not_notify = [commenter] # Never notify thyself!
    end

    # Order matters, because notified users are added to `@do_not_notify`,
    # since we only want to send one notification to each user.
    # If a user was notified because they were replied to, we're not sending
    # another three notification in case they are also the creator of the
    # commentable, active in the same discussion, and mentioned in the comment.
    def call
      notify_replied_to_user
      notify_mentioned_users
      notify_users_in_the_same_discussion
      notify_commentable_creator
    end

    private
      attr_accessor :comment, :do_not_notify
      delegate :commenter, :commentable, :body, :parent, :is_a_reply?, to: :comment

      def notify_replied_to_user
        return unless is_a_reply?

        replied_to_user = parent.commenter
        notify replied_to_user, :was_replied_to
      end

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
        Markdowns::MentionedUsers.new(body).call
      end

      # TODO improve and move somewhere.
      def notify_creator?
        # These are the only models for which we want to notify
        # the creator about. TODO see if we can make use of
        # `enable_user_notifications_for` instead of this.
        return unless commentable.class.in? [Issue, SiteNotice, Feedback]

        # Unregistered users can submit feedback, but we only want to
        # notify submitters who are registered users.
        return if commentable.is_a?(Feedback) && commentable.user.blank?
        true
      end

      def notify user, reason
        return if do_not_notify? user

        user.notify_because reason, attached: comment, notifier: commenter
        no_more_notifications_for user
      end

      def do_not_notify? user
        user.in? do_not_notify
      end

      def no_more_notifications_for user
        do_not_notify << user
      end
  end
end
