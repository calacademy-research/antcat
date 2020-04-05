# frozen_string_literal: true

module Users
  class Notify
    include Service

    attr_private_initialize :user, :reason, [:attached, :notifier]

    def call
      return if notifier == user
      return if already_notified_for_attached_by_notifier?

      notification = user.notifications.create!(reason: reason, attached: attached, notifier: notifier)
      send_email_notification user, notification
    end

    private

      # To avoid sending repeated notifications eg when a comment that
      # already mentions a user is edited and saved again.
      def already_notified_for_attached_by_notifier?
        user.notifications.where(attached: attached, notifier: notifier).exists?
      end

      def send_email_notification user, notification
        UserMailer.new_notification(user, notification).deliver_now
      end
  end
end
