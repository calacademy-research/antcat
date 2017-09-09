class UserDecorator < Draper::Decorator
  delegate_all

  def name_linking_to_email
    helpers.link_to user.name, "mailto:#{user.email}"
  end

  def user_page_link
    helpers.link_to user.name, helpers.user_path(user)
  end

  # Like `#user_page_link` but with an "@".
  def ping_user_link
    helpers.link_to "@<strong>#{user.name}</strong>".html_safe, helpers.user_path(user)
  end
end
