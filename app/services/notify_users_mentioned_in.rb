class NotifyUsersMentionedIn
  include Service

  def initialize string, attached:, notifier:
    @string = string
    @attached = attached
    @notifier = notifier
  end

  def call
    Markdowns::MentionedUsers[string].each do |user|
      user.notify_because Notification::MENTIONED_IN_THING, attached: attached, notifier: notifier
    end
  end

  private

    attr_reader :string, :attached, :notifier
end
