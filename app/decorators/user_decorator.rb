class UserDecorator < Draper::Decorator
  delegate_all

  def name_linking_to_email
    helpers.link_to user.name, "mailto:#{user.email}"
  end

end
