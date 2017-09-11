class UserDecorator < Draper::Decorator
  delegate :name, :email

  def user_page_link
    helpers.link_to name, user
  end

  # Like `#user_page_link` but with an "@".
  def ping_user_link
    helpers.link_to "@<strong>#{name}</strong>".html_safe, user
  end
end
