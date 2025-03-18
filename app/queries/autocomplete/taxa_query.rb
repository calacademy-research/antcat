# frozen_string_literal: true

module Autocomplete
  class TaxaQuery
    include Service

    TAXON_ID_REGEX = /^\d+ ?$/

    def initialize search_query, rank: nil, page: 1, per_page: 30
      @search_query = search_query
      @rank = Array.wrap(rank).presence
      @page = page
      @per_page = per_page
    end

    def call
      exact_id_match || search_results
    end

    private

      attr_reader :search_query, :rank, :page, :per_page

      def exact_id_match
        return unless search_query.match?(TAXON_ID_REGEX)
        Taxon.where(id: search_query).presence
      end

      def search_results
        Taxon.solr_search(include: [:name, { protonym: [:name, { authorship: :reference }] }]) do |solr|
          solr.keywords search_query do
            fields(:name_cache)
            fields(:authors)
            fields(:year_as_string)

            boost_fields(name_cache: 2.0)
          end

          if rank
            solr.with(:type).any_of(rank)
          end

          solr.paginate(page: page, per_page: per_page)
        end.results
      end
  end
end
