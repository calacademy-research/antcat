# frozen_string_literal: true

module Autocomplete
  class ProtonymsQuery
    include Service

    PROTONYM_ID_REGEX = /^\d+ ?$/

    attr_private_initialize :search_query

    def call
      exact_id_match || search_results
    end

    private

      def exact_id_match
        return unless search_query.match?(PROTONYM_ID_REGEX)

        match = Protonym.find_by(id: search_query)
        [match] if match
      end

      def search_results
        Protonym.
          joins(:name).
          where("names.name LIKE ? OR names.name LIKE ?", crazy_search_query, not_as_crazy_search_query).
          take(10)
      end

      def crazy_search_query
        search_query.split('').join('%') + '%'
      end

      def not_as_crazy_search_query
        "%#{search_query}%"
      end
  end
end
