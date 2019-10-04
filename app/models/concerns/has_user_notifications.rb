# For notifying users mentioned in descriptions/messages/anything.

module HasUserNotifications
  def notify_users_mentioned_in string, notifier:
    Markdowns::MentionedUsers[string].each do |user|
      user.notify_because :mentioned_in_thing, attached: self, notifier: notifier
    end
  end
end
