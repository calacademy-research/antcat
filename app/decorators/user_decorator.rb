# TODO probably convert to a helper.

class UserDecorator < Draper::Decorator
  delegate_all

  def name_linking_to_email
    helpers.link_to user.name, "mailto:#{user.email}"
  end

  def user_page_link
    helpers.link_to user.name, helpers.user_path(user)
  end
end
