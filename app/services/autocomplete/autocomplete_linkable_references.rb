module Autocomplete
  class AutocompleteLinkableReferences
    include Service

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
        exact_id_match || fulltext_search_light(search_query)
      end

      def exact_id_match
        return unless search_query =~ /^\d{6} ?$/

        match = Reference.find_by id: search_query
        [match] if match
      end

      # Fulltext search, but not all fields. Used by at.js.
      def fulltext_search_light search_keywords
        Reference.solr_search do
          keywords search_keywords do
            fields(:title, :author_names_string, :citation_year)
          end

          paginate page: 1, per_page: 10
        end.results
      end
  end
end
