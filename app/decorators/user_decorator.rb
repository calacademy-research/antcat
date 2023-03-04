# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  delegate :name, :email, :editor?, :at_least_helper?

  def user_page_link
    h.link_to name, user
  end

  def ping_user_link
    h.link_to "@#{name}", user, class: 'font-bold'
  end

  def email_address_with_name
    ActionMailer::Base.email_address_with_name(email, name)
  end

  def user_badge
    return unless at_least_helper?

    if editor?
      label = "editor ".html_safe << h.antcat_icon("star")
      h.tag.span label, class: "badge-blue"
    else
      label = "helper ".html_safe << h.antcat_icon("black-star")
      h.tag.span label, class: "badge-white"
    end
  end
end
