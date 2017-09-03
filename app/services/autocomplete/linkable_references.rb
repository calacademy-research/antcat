module Autocomplete
  class LinkableReferences
    def initialize search_query
      @search_query = search_query
    end

    def call
      search_results.map do |reference|
        {
          id: reference.id,
          author: reference.author_names_string,
          year: reference.citation_year,
          title: reference.decorate.format_title
        }
      end
    end

    private
      attr_reader :search_query

      def search_results
        exact_id_match || Reference.fulltext_search_light(search_query)
      end

      def exact_id_match
        return unless search_query =~ /^\d{6} ?$/

        match = Reference.find_by id: search_query
        [match] if match
      end
  end
end
