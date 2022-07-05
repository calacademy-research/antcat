# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def new_notification user, notification
    return unless user.enable_email_notifications?

    @user = user
    @notification = notification

    mail(
      to: @user.decorate.angle_bracketed_email,
      subject: 'New notification - antcat.org'
    )
  end
end
