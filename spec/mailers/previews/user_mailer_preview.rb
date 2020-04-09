# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def new_notification
    user = User.find(60)
    UserMailer.new_notification(user, user.notifications.last)
  end
end
