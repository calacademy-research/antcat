class FeedbackMailer < ApplicationMailer
  def feedback_email feedback
    @feedback = feedback
    @user = feedback.user

    to = "sblum@calacademy.org" # FIX hardcoded

    subject = "AntCat Feedback ##{feedback.id}"
    mail to: to, subject: subject
  end
end
