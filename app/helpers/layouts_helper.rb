module LayoutsHelper
  def current_controller_css_id controller_name
    "#{controller_name.tr('/', '_')}-controller"
  end

  def title_tag title
    string = ''.html_safe
    string << "#{title} - " if title
    string << "AntCat"
    string << (Rails.env.production? ? '' : " (#{Rails.env})")
    string
  end
end
