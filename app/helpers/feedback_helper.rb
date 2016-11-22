module FeedbackHelper
  def format_submitter_name feedback
    user = feedback.user
    return user.decorate.user_page_link if user

    name = feedback.name.presence || "[no name]"
    email = feedback.email.presence || "[no email]; IP #{feedback.ip}"
    "#{name} <#{email}>"
  end

  def format_feedback_for_pre feedback
    from =  if user = feedback.user
              "#{user.angle_bracketed_email} (registered AntCat user)"
            else
              name = feedback.name.presence || "[no name]"
              email = feedback.email.presence || "[no email]; IP #{feedback.ip}"
              "#{name} <#{email}>"
            end

    page = if feedback.page
            "http://antcat.org/#{feedback.page}"
          else
            "(none)"
          end

    <<-MESSAGE
-------- Original Message --------
From: #{from}
Sent: #{feedback.created_at}
To: AntCat
Subject: AntCat Feedback (ID #{feedback.id})

Page: #{page}

#{strip_tags(feedback.comment)}
    MESSAGE
  end
end
