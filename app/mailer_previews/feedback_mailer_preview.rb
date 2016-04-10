class FeedbackMailerPreview
  def feedback_email
    feedback = Feedback.last
    FeedbackMailer.feedback_email feedback
  end
end
