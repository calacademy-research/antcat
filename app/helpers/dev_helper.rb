module DevHelper
  # Show link to localhost on live site and vice versa because I am lazy.
  def link_to_current_page_on_live_site_or_localhost
    if Rails.env.development?
      link_to "on antcat.org", current_url_on_live_site, class: "show-on-hover"
    else
      link_to "on localhost", current_url_on_localhost, class: "show-on-hover"
    end
  end

  # dev-specific CSS. Disable by suffixing the url with ?no_dev_css=pizza,
  # or toggling on/off from the Editor's Panel.
  def include_dev_css?
    return false unless Rails.env.development?
    return false if params[:no_dev_css] || session[:no_dev_css]
    true
  end

  private

    def current_url_on_live_site
      "https://antcat.org#{request.path}"
    end

    def current_url_on_localhost
      "http://localhost:3000#{request.path}"
    end
end
