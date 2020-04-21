# frozen_string_literal: true

module Autocomplete
  class ReferencesQuery
    include Service

    PER_PAGE = 10
    REFERENCE_ID_REGEX = /^\d+ ?$/

    attr_private_initialize :search_query, :keyword_params

    def call
      exact_id_match || search_results
    end

    private

      def search_results
        ::References::FulltextSearchQuery[{ per_page: PER_PAGE }.merge(keyword_params)]
      end

      def exact_id_match
        return unless search_query.match?(REFERENCE_ID_REGEX)

        match = Reference.find_by(id: search_query)
        [match] if match
      end
  end
end
