module FeedbackHelper
  def format_submitter_name feedback
    user = feedback.user
    return user.decorate.user_page_link if user

    name = feedback.name.presence || "[no name]"
    email = feedback.email.presence || "[no email]; IP #{feedback.ip}"
    "#{name} <#{email}>"
  end
end
