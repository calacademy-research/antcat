# frozen_string_literal: true

module Autocomplete
  class LinkableReferencesQuery
    include Service

    REFERENCE_ID_REGEX = /^\d+ ?$/

    attr_private_initialize :search_query

    def call
      search_results
    end

    private

      def search_results
        exact_id_match || References::FulltextSearchLightQuery[search_query]
      end

      def exact_id_match
        return unless search_query.match?(REFERENCE_ID_REGEX)

        match = Reference.find_by(id: search_query)
        [match] if match
      end
  end
end
