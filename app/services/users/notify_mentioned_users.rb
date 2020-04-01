# frozen_string_literal: true

module Users
  class NotifyMentionedUsers
    include Service

    attr_private_initialize :string, [:attached, :notifier]

    def call
      Markdowns::MentionedUsers[string].each do |user|
        Users::Notify[user, Notification::MENTIONED_IN_THING, attached: attached, notifier: notifier]
      end
    end
  end
end
