# frozen_string_literal: true

class FeedbackDecorator < Draper::Decorator
  delegate :user, :id, :comment, :created_at, :ip

  def format_submitter_name
    return user.decorate.user_page_link if user
    format_unregistered_submitter
  end

  def format_page
    return unless (url = full_feedback_page_url)
    h.tag.p "Page: #{h.link_to(url, url)}".html_safe
  end

  def format_feedback_for_email
    from = if user
             user.decorate.angle_bracketed_email
           else
             format_unregistered_submitter
           end

    <<~MESSAGE
      Thank you for contributing to AntCat.

      If you wish to register an account, sign up at #{h.new_user_registration_url(host: 'antcat.org')}

      -------- Original Message --------
      From: #{from}
      Sent: #{created_at}
      To: AntCat
      Subject: AntCat Feedback (ID #{id})

      Page: #{full_feedback_page_url || '(none)'}

      #{h.strip_tags(comment)}
    MESSAGE
  end

  private

    def full_feedback_page_url
      return if feedback.page.blank?
      "#{Settings.production_url}/#{feedback.page}"
    end

    def format_unregistered_submitter
      name = feedback.name.presence || "[no name]"
      email = feedback.email.presence || "[no email]; IP #{ip}"
      "#{name} <#{email}>"
    end
end
