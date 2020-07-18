# frozen_string_literal: true

module DevHelper
  # Show link to localhost on live site and vice versa because I am lazy.
  def link_to_current_page_on_live_site_or_localhost
    non_blank_query_params = request.query_parameters.dup.delete_if { |_key, value| value.blank? } # To make URLs prettier.
    query_params = "?#{non_blank_query_params.to_param}" if non_blank_query_params.present?

    path = "#{request.path}#{query_params}"

    if Rails.env.development?
      link_to "on antcat.org", "#{Settings.production_url}#{path}", class: "show-on-hover"
    else
      link_to "on localhost", "http://localhost:3000#{path}", class: "show-on-hover"
    end
  end
end
