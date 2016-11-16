# Dev only.

module DevHelper
  def link_to_current_page_on_live_site
    link_to "on antcat.org", current_url_on_live_site,
      class: "btn-tiny", title: "This link is only visivle in development."
  end

  def current_url_on_live_site
    "http://antcat.org/#{request.path}"
  end
end
