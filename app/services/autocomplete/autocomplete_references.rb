# frozen_string_literal: true

module Autocomplete
  class AutocompleteReferences
    include Service

    PER_PAGE = 10

    attr_private_initialize :search_query

    def call
      search_results.map do |reference|
        search_query = if keyword_params.size == 1 # size 1 == no keyword params were matched.
                         reference.title
                       else
                         format_autosuggest_keywords reference, keyword_params
                       end
        {
          search_query: search_query,
          id: reference.id,
          title: reference.title,
          author: reference.author_names_string_with_suffix,
          year: reference.citation_year_and_stated_year
        }
      end
    end

    private

      def search_results
        exact_id_match || ::References::Search::Fulltext[{ per_page: PER_PAGE }.merge keyword_params]
      end

      def exact_id_match
        return unless /^\d{6} ?$/.match?(search_query)

        match = Reference.find_by(id: search_query)
        [match] if match
      end

      def keyword_params
        @_keyword_params ||= ::References::Search::ExtractKeywords[search_query]
      end

      def format_autosuggest_keywords reference, keyword_params
        replaced = []
        replaced << keyword_params[:keywords] || ''
        replaced << "author:'#{reference.author_names_string}'" if keyword_params[:author]
        replaced << "title:'#{reference.title}'" if keyword_params[:title]
        replaced << "year:#{keyword_params[:year]}" if keyword_params[:year]

        start_year = keyword_params[:start_year]
        end_year   = keyword_params[:end_year]
        if start_year && end_year
          replaced << "year:#{start_year}-#{end_year}"
        end
        replaced.join(" ").strip
      end
  end
end
