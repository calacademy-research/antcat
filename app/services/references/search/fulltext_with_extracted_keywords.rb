module References
  module Search
    class FulltextWithExtractedKeywords
      include Service

      def initialize search_query, page: nil, per_page: nil
        @search_query = search_query.dup
        @page = page
        @per_page = per_page
      end

      def call
        References::Search::Fulltext[keyword_params]
      end

      private

        attr_reader :search_query, :page, :per_page

        def keyword_params
          References::Search::ExtractKeywords[search_query].merge(search_options)
        end

        def search_options
          { page: page, per_page: per_page }
        end
    end
  end
end
