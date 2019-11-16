module Autocomplete
  class AutocompleteLinkableReferences
    include Service

    def initialize search_query
      @search_query = search_query
    end

    def call
      Autocomplete::FormatLinkableReferences[search_results]
    end

    private

      attr_reader :search_query

      def search_results
        exact_id_match || References::Search::FulltextLight[search_query]
      end

      def exact_id_match
        return unless search_query =~ /^\d+ ?$/

        match = Reference.find_by(id: search_query)
        [match] if match
      end
  end
end
