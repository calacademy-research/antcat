module LayoutsHelper
  # For namespacing stylesheet assets.
  def current_controller_css_id
    "#{params[:controller].tr('/', '_')}-controller"
  end

  # The <title> tag which is shown on all pages.
  def make_title title
    string = ''.html_safe
    string << "#{title} - " if title
    string << "AntCat"
    string << (Rails.env.production? ? '' : " (#{Rails.env})")
    string
  end
end
