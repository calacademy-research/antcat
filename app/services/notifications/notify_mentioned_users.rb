# frozen_string_literal: true

# Notifies the users mentioned in a text attached to a record.
module Notifications
  class NotifyMentionedUsers
    include Service

    attr_private_initialize :string, [:attached, :notifier]

    def call
      Markdowns::MentionedUsers[string].each do |user|
        Notifications::NotifyUser[user, Notification::MENTIONED_IN_ATTACHED, attached: attached, notifier: notifier]
      end
    end
  end
end
