class FeedbackDecorator < Draper::Decorator
  delegate :user, :id, :comment, :created_at, :ip

  def format_submitter_name
    return user.decorate.user_page_link if user
    format_unregistered_submitter
  end

  # TODO: Do not hardcode antcat.org.
  def format_page
    url = "https://antcat.org/#{feedback.page}"
    helpers.content_tag :p, "Page: #{helpers.link_to(url, url)}".html_safe
  end

  def format_feedback_for_email
    from = if user
             user.decorate.angle_bracketed_email
           else
             format_unregistered_submitter
           end

    # TODO: Do not hardcode antcat.org.
    page = if feedback.page
             "https://antcat.org/#{feedback.page}"
           else
             "(none)"
           end

    <<~MESSAGE
      Thank you for contributing to AntCat.

      If you wish to register an account, sign up at #{h.new_user_registration_url(host: 'antcat.org')}

      -------- Original Message --------
      From: #{from}
      Sent: #{created_at}
      To: AntCat
      Subject: AntCat Feedback (ID #{id})

      Page: #{page}

      #{helpers.strip_tags(comment)}
    MESSAGE
  end

  private

    def format_unregistered_submitter
      name = feedback.name.presence || "[no name]"
      email = feedback.email.presence || "[no email]; IP #{ip}"
      "#{name} <#{email}>"
    end
end
