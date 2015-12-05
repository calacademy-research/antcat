class UserDecorator < Draper::Decorator
  delegate_all

  def format_name_linking_to_email
    helpers.content_tag(:a, user.name, href: %{mailto:#{user.email}}.html_safe)
  end

  def format_doer_name
    format_name_linking_to_email || 'Someone'
  end

end
