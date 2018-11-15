class UserDecorator < Draper::Decorator
  delegate :name, :email, :is_editor?, :is_at_least_helper?

  def user_page_link
    helpers.link_to name, user
  end

  def ping_user_link
    helpers.link_to "@<strong>#{name}</strong>".html_safe, user
  end

  def angle_bracketed_email
    %("#{name}" <#{email}>)
  end

  def user_badge
    return unless is_at_least_helper?

    if is_editor?
      helpers.content_tag :span, "editor", class: "label"
    else
      helpers.content_tag :span, "helper", class: "white-label"
    end
  end
end
