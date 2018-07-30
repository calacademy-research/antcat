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
          title: reference.decorate.format_title,
          full_pagination: full_pagination(reference),
          bolton_key: bolton_key(reference)
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
      # TODO we may want to use the same order/boost for `References::Search::Fulltext`.
      def fulltext_search_light search_keywords
        Reference.solr_search do
          keywords search_keywords do
            fields :title, :author_names_string, :citation_year
            boost_fields author_names_string: 5.0
            boost_fields citation_year: 2.0
          end

          order_by :score, :desc
          order_by :author_names_string, :desc
          order_by :citation_year, :asc
          paginate page: 1, per_page: 10
        end.results
      end

      def full_pagination reference
        if reference.is_a? NestedReference
          "[pagination: #{reference.pages_in} (#{reference.nesting_reference.pagination})]"
        elsif reference.pagination
          "[pagination: #{reference.pagination}]"
        else
          ""
        end
      end

      def bolton_key reference
        return "" unless reference.bolton_key
        "[Bolton key: #{reference.bolton_key}]"
      end
  end
end
