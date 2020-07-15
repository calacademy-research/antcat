# frozen_string_literal: true

module DevHelper
  # Show link to localhost on live site and vice versa because I am lazy.
  def link_to_current_page_on_live_site_or_localhost
    query_params = "?#{request.query_parameters.to_param}" if request.query_parameters.present?
    path = "#{request.path}#{query_params}"

    if Rails.env.development?
      link_to "on antcat.org", "#{Settings.production_url}#{path}", class: "show-on-hover"
    else
      link_to "on localhost", "http://localhost:3000#{path}", class: "show-on-hover"
    end
  end
end
