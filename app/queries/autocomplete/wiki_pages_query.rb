# frozen_string_literal: true

module Autocomplete
  class WikiPagesQuery
    include Service

    WIKI_PAGE_ID_REGEX = /^\d+ ?$/

    attr_private_initialize :search_query

    def call
      exact_id_match || search_results
    end

    private

      def exact_id_match
        return unless search_query.match?(WIKI_PAGE_ID_REGEX)
        WikiPage.where(id: search_query).presence
      end

      def search_results
        WikiPage.where("title LIKE ?", "%#{search_query}%")
      end
  end
end
