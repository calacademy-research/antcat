# For notifying users mentioned in descriptions/messages/anything.

module SendsNotifications
  extend ActiveSupport::Concern

  module ClassMethods
    def enable_user_notifications_for field
      after_save do
        notify_mentioned_users_in send(field)
      end
    end
  end

  def notify_mentioned_users_in string
    Markdowns::MentionedUsers.new(string).call.each do |user|
      user.notify_because :mentioned_in_thing, attached: self, notifier: User.current
    end
  end
end
