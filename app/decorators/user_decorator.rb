# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  delegate :name, :email, :editor?, :at_least_helper?

  def user_page_link
    h.link_to name, user
  end

  def ping_user_link
    h.link_to "@#{name}", user, class: 'user-mention'
  end

  def angle_bracketed_email
    %("#{name}" <#{email}>)
  end

  def user_badge
    return unless at_least_helper?

    if editor?
      label = "editor ".html_safe << h.antcat_icon("star")
      h.content_tag :span, label, class: "label rounded-badge"
    else
      label = "helper ".html_safe << h.antcat_icon("black-star")
      h.content_tag :span, label, class: "white-label rounded-badge"
    end
  end
end
