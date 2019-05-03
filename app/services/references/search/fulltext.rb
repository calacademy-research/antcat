module References
  module Search
    class Fulltext
      include Service

      def initialize options = {}
        @options = options
      end

      def call
        fulltext_search
      end

      private

        attr_reader :options

        def fulltext_search
          page            = options[:page] || 1
          items_per_page  = options[:items_per_page] || 30
          year            = options[:year]
          start_year      = options[:start_year]
          end_year        = options[:end_year]
          author          = options[:author]
          title           = options[:title]
          doi             = options[:doi]

          # Hyphens, asterixes and colons makes Solr go bananas.
          title = title.gsub(/-|:|\*/, ' ') if title
          author = author.gsub(/-|:/, ' ') if author

          Reference.search(include: [:document]) do
            keywords normalized_search_keywords

            if title
              keywords title do
                fields(:title)
              end
            end

            if author
              keywords author do
                fields(:author_names_string)
              end
            end

            if year
              with(:year).equal_to year
            end

            if start_year && end_year
              with(:year).between(start_year..end_year)
            end

            if doi
              with(:doi).equal_to doi
            end

            case options[:reference_type]
            when :unknown   then with    :type, 'UnknownReference'
            when :nested    then with    :type, 'NestedReference'
            when :missing   then with    :type, 'MissingReference'
            when :nomissing then without :type, 'MissingReference'
            else                 without :type, 'MissingReference'
            end

            if options[:endnote_export]
              paginate page: 1, per_page: 9999999 # Hehhehe.
            elsif page
              paginate page: page, per_page: items_per_page
            end

            order_by :score, :desc
            order_by :author_names_string, :desc
            order_by :citation_year, :asc
          end.results
        end

        # TODO: This is partially duplicated in `References::Search::FulltextLight`.
        def normalized_search_keywords
          @normalized_search_keywords ||= begin
            keywords = options[:keywords] || ""

            # TODO very ugly to make some queries work. Fix in Solr.
            substrings_to_remove = ['<i>', '</i>', '\*'] # Titles may contain these.
            substrings_to_remove.each { |substring| keywords.gsub! /#{substring}/, '' }

            # Hyphens, asterixes and colons makes Solr go bananas.
            keywords.gsub! /-|:/, ' '

            keywords
          end
        end
    end
  end
end
