# frozen_string_literal: true

module Autocomplete
  class ProtonymsQuery
    include Service

    PROTONYM_ID_REGEX = /^\d+ ?$/

    def initialize search_query, page: 1, per_page: 30
      @search_query = search_query
      @page = page
      @per_page = per_page
    end

    def call
      exact_id_match || search_results
    end

    private

      attr_reader :search_query, :page, :per_page

      def exact_id_match
        return unless search_query.match?(PROTONYM_ID_REGEX)
        Protonym.where(id: search_query).presence
      end

      def search_results
        Protonym.solr_search(include: [:name, { authorship: :reference }]) do
          keywords search_query do
            fields(:name)
            fields(:authors)
            fields(:year_as_string)

            boost_fields name: 2.0
          end

          paginate page: page, per_page: per_page
        end.results
      end
  end
end
