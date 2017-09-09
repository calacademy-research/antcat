# Dev only.

module DevHelper
  def link_to_current_page_on_live_site
    link_to "on antcat.org", current_url_on_live_site,
      class: "btn-tiny", title: "This link is only visivle in development."
  end

  def current_url_on_live_site
    "http://antcat.org#{request.path}"
  end

  # dev-specific CSS. Disable by suffixing the url with ?no_dev_css=pizza,
  # or toggling on/off from the Editor's Panel.
  def include_dev_css?
    return unless Rails.env.development?
    return if params[:no_dev_css] || session[:no_dev_css]
    true
  end
end
