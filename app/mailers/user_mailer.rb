# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def new_notification user, notification
    return unless user.enable_email_notifications?

    @user = user
    @notification = notification
    @unsubscribe_token = ubsubscribe_token(@user)

    mail(
      to: @user.decorate.angle_bracketed_email,
      subject: 'New notification - antcat.org'
    )
  end
end
