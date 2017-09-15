module References
  module Search
    class FulltextWithExtractedKeywords
      include Service

      def initialize options = {}
        @options = options
      end

      def call
        Reference.fulltext_search options.merge(keyword_params)
      end

      private
        attr_reader :options

        def keyword_params
          References::ExtractKeywordParams[search_query]
        end

        def search_query
          if options[:q].present? then options[:q].dup else "" end
        end
    end
  end
end
