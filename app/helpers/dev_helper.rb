# frozen_string_literal: true

module DevHelper
  # Show link to localhost on live site and vice versa because I am lazy.
  def link_to_current_page_on_live_site_or_localhost
    path = current_path_without_blank_params

    if Rails.env.development?
      link_to "pr", "#{Settings.production_url}#{path}"
    else
      link_to "lo", "http://localhost:3000#{path}"
    end
  end

  def link_to_current_page_on_live_site_from_staging
    link_to "pr", "#{Settings.production_url}#{current_path_without_blank_params}"
  end

  private

    # To make URLs prettier.
    def current_path_without_blank_params
      non_blank_query_params = request.query_parameters.dup.compact_blank!
      query_params = "?#{non_blank_query_params.to_param}" if non_blank_query_params.present?
      "#{request.path}#{query_params}"
    end
end
