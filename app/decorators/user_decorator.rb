class UserDecorator < Draper::Decorator
  delegate :name, :email, :is_editor?, :is_at_least_helper?

  def user_page_link
    helpers.link_to name, user
  end

  def ping_user_link
    helpers.link_to "@#{name}", user, class: 'user-mention'
  end

  def angle_bracketed_email
    %("#{name}" <#{email}>)
  end

  def user_badge
    return unless is_at_least_helper?

    if is_editor?
      label = "editor ".html_safe << helpers.antcat_icon("star")
      helpers.content_tag :span, label, class: "label rounded-badge"
    else
      label = "helper ".html_safe << helpers.antcat_icon("black-star")
      helpers.content_tag :span, label, class: "white-label rounded-badge"
    end
  end
end
