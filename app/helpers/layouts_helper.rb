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

  def subnavigation_menu *items
    content_tag :span do |_content|
      items.flatten.reduce(''.html_safe) do |string, item|
        string << ' | '.html_safe unless string.empty?
        string << item
      end
    end
  end
end
