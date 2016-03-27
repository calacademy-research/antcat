class FeedbackMailer < ApplicationMailer
  def feedback_email feedback
    feedback.update_attributes email_recipients: emails_with_names

    subject = "AntCat Feedback ##{feedback.id}"
    mail to: feedback.email_recipients, subject: subject do |format|
      format.html {
        render locals: { feedback: feedback }
      }
    end
  end

  private
    def emails_with_names
      User.feedback_emails_recipients.map(&:angle_bracketed_email)
        .join(", ").presence || "sblum@calacademy.org"
    end
end
