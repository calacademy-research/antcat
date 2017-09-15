module Autocomplete
  class References
    include Service

    def initialize search_query
      @search_query = search_query
    end

    def call
      search_results.map do |reference|
        search_query = if keyword_params.size == 1 # size 1 = no keyword params were matched
                         reference.title
                       else
                         format_autosuggest_keywords reference, keyword_params
                       end
        {
          search_query: search_query,
          title: reference.title,
          author: reference.author_names_string,
          year: reference.citation_year
        }
      end
    end

    private
      attr_reader :search_query

      def search_results
        ::References::Search::Fulltext[search_options]
      end

      def search_options
        { reference_type: :nomissing, items_per_page: 5 }.merge keyword_params
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
