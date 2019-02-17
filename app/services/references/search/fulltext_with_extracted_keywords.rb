module References
  module Search
    class FulltextWithExtractedKeywords
      include Service

      def initialize options = {}
        @options = options
      end

      def call
        References::Search::Fulltext[keyword_params]
      end

      private

        attr_reader :options

        def keyword_params
          References::Search::ExtractKeywords[search_query].
            merge(search_options)
        end

        def search_query
          if options[:q].present? then options[:q].dup else "" end
        end

        # TODO: Extract `options[:q]` to a params and improve this.
        def search_options
          {
            page: options[:page],
            endnote_export: options[:endnote_export]
          }
        end
    end
  end
end
