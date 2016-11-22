module FeedbackHelper
  def format_submitter_name feedback
    return feedback.user.decorate.user_page_link if feedback.user
    format_unregistered_user feedback
  end

  def format_feedback_page feedback
    url = "http://antcat.org/#{feedback.page}"
    content_tag :p, "Page: #{link_to(url, url)}".html_safe
  end

  def format_feedback_for_email feedback
    from =  if feedback.user
              feedback.user.angle_bracketed_email
            else
              format_unregistered_user feedback
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

  private
    def format_unregistered_user feedback
      name = feedback.name.presence || "[no name]"
      email = feedback.email.presence || "[no email]; IP #{feedback.ip}"
      "#{name} <#{email}>"
    end
end
