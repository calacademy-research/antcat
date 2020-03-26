# frozen_string_literal: true

module DevHelper
  # Show link to localhost on live site and vice versa because I am lazy.
  def link_to_current_page_on_live_site_or_localhost
    if Rails.env.development?
      link_to "on antcat.org", "https://antcat.org#{request.path}", class: "show-on-hover"
    else
      link_to "on localhost", "http://localhost:3000#{request.path}", class: "show-on-hover"
    end
  end
end
