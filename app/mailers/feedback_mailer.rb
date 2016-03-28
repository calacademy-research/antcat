class FeedbackMailer < ApplicationMailer
  def feedback_email feedback
    recipients = feedback.email_recipients
    subject = "AntCat Feedback ##{feedback.id}"

    mail to: recipients, subject: subject do |format|
      format.html {
        render locals: { feedback: feedback }
      }
    end
  end
end
