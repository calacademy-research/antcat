module LayoutsHelper
  def current_controller_css_id controller_name
    "#{controller_name.tr('/', '_')}-controller"
  end

  def title title
    content_for :title_tag, title
  end

  def title_tag
    title = content_for :title_tag

    string = ''.html_safe
    string << "#{title} - " if title
    string << "AntCat"
    string << " (#{Rails.env})" unless Rails.env.production?
    string
  end
end
