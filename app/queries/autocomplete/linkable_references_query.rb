# frozen_string_literal: true

module Autocomplete
  class LinkableReferencesQuery
    include Service

    REFERENCE_ID_REGEX = /^\d+ ?$/

    attr_private_initialize :search_query

    def call
      exact_id_match || search_results
    end

    private

      def exact_id_match
        return unless search_query.match?(REFERENCE_ID_REGEX)
        Reference.where(id: search_query).presence
      end

      def search_results
        References::FulltextSearchLightQuery[search_query]
      end
  end
end
