# frozen_string_literal: true

module References
  module Search
    class FulltextWithExtractedKeywords
      include Service

      attr_private_initialize :search_query, [page: nil, per_page: nil]

      def call
        References::Search::Fulltext[keyword_params]
      end

      private

        def keyword_params
          References::Search::ExtractKeywords[search_query].merge(search_options)
        end

        def search_options
          { page: page, per_page: per_page }
        end
    end
  end
end
