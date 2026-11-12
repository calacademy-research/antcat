# frozen_string_literal: true

module Api
  class ApiController < ApplicationController
    include ApiKeyAccess # Keys and limits; off unless `Settings.api_keys.enabled`.

    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end

    private

      # Page size: 100 records, or the caller's records per page when API keys are on (see `ApiAccess`).
      def with_limit scope
        if params[:starts_at]
          scope.where('id >= ?', params[:starts_at].to_i)
        else
          scope
        end.order(id: :asc).limit(api_records_per_page)
      end

      # Hidden editor notes (`{hiddennote ...}` in taxt) are shown on the site to signed-in users only.
      # The API is open to everyone, so they are removed from every string in the response.
      def without_hidden_notes json
        case json
        when Hash then json.transform_values { without_hidden_notes(it) }
        when Array then json.map { without_hidden_notes(it) }
        else Taxt.remove_hidden_notes(json)
        end
      end
  end
end
