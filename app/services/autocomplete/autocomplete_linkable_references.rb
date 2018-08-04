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
        exact_id_match || References::Search::FulltextLight[search_query]
      end

      def exact_id_match
        return unless search_query =~ /^\d{6} ?$/

        match = Reference.find_by id: search_query
        [match] if match
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
