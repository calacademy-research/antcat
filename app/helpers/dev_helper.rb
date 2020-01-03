module DevHelper
  def link_to_current_page_on_live_site
    link_to "on antcat.org", current_url_on_live_site,
      class: "show-on-hover", title: "This link is only visivle in development."
  end

  # Show link to localhost on live site because I am lazy.
  def link_to_current_page_on_localhost
    link_to "on localhost", current_url_on_localhost,
      class: "show-on-hover",
      title: "Link to localhost (dev). This link is only shown to superadmins."
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
      "http://antcat.org#{request.path}"
    end

    def current_url_on_localhost
      "http://localhost:3000#{request.path}"
    end
end
