# frozen_string_literal: true

module Notifications
  class NotifyMentionedUsers
    include Service

    attr_private_initialize :string, [:attached, :notifier]

    def call
      Markdowns::MentionedUsers[string].each do |user|
        Notifications::NotifyUser[user, Notification::MENTIONED_IN_THING, attached: attached, notifier: notifier]
      end
    end
  end
end
