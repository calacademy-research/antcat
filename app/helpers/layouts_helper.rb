# frozen_string_literal: true

module LayoutsHelper
  def controller_css_class controller_name
    "#{controller_name.tr('/', '_')}-controller"
  end

  def rails_env_css_class
    return if cookies[:disable_env_css] == "yes"
    "rails-env-#{Rails.env}"
  end

  def page_title title
    content_for :title_tag, title
  end

  def title_tag
    string = ''.html_safe
    if (title = content_for(:title_tag))
      string << title
      string << " - "
    end
    string << "AntCat"
    string
  end
end
