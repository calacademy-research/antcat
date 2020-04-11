# frozen_string_literal: true

module Autocomplete
  class AutocompleteWikiPages
    include Service

    attr_private_initialize :search_query

    def call
      search_results
    end

    private

      def search_results
        exact_id_match || WikiPage.where("title LIKE ?", "%#{search_query}%")
      end

      def exact_id_match
        return unless /^\d+ ?$/.match?(search_query)

        match = WikiPage.find_by(id: search_query)
        [match] if match
      end
  end
end
