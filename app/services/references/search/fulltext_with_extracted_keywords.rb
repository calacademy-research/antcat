module References
  module Search
    class FulltextWithExtractedKeywords
      include Service

      def initialize search_query, page: nil, endnote_export: false
        @search_query = search_query.dup
        @page = page
        @endnote_export = endnote_export
      end

      def call
        References::Search::Fulltext[keyword_params]
      end

      private

        attr_reader :search_query, :page, :endnote_export

        def keyword_params
          References::Search::ExtractKeywords[search_query].
            merge(search_options)
        end

        def search_options
          { page: page, endnote_export: endnote_export }
        end
    end
  end
end
