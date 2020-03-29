# frozen_string_literal: true

module References
  module Search
    class Fulltext
      include Service

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        keywords: '', title: nil, author: nil, year: nil, start_year: nil, end_year: nil,
        doi: nil, reference_type: nil, page: 1, per_page: 30
      )
        @keywords = keywords # TODO: Probably rename to `freetext` since most params are "keywords".
        # Hyphens, asterixes and colons makes Solr go bananas.
        @title = title.gsub(/-|:|\*/, ' ') if title
        @author = author.gsub(/-|:/, ' ') if author
        @year = year
        @start_year = start_year
        @end_year = end_year
        @doi = doi
        @reference_type = reference_type
        @page = page
        @per_page = per_page
      end
      # rubocop:enable Metrics/ParameterLists

      def call
        fulltext_search
      end

      private

        attr_reader :keywords, :title, :author, :year, :start_year, :end_year, :doi,
          :reference_type, :page, :per_page

        def fulltext_search
          Reference.search(include: [:document]) do # rubocop:disable Metrics/BlockLength
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

            case reference_type
            when :unknown   then with    :type, 'UnknownReference'
            when :nested    then with    :type, 'NestedReference'
            when :missing   then with    :type, 'MissingReference'
            when :nomissing then without :type, 'MissingReference'
            end

            # TODO: Super hack that will go away with `MissingReference`s.
            if per_page == 999_999
              without :type, 'MissingReference'
            end

            paginate page: page, per_page: per_page

            order_by :score, :desc
            order_by :author_names_string, :desc
            order_by :citation_year, :asc
          end.results
        end

        # TODO: This is partially duplicated in `References::Search::FulltextLight`.
        def normalized_search_keywords
          keywords_dup = keywords.dup

          # TODO: Very ugly to make some queries work. Fix in Solr.
          substrings_to_remove = ['<i>', '</i>', '\*'] # Titles may contain these.
          substrings_to_remove.each { |substring| keywords_dup.gsub!(/#{substring}/, '') }

          # Hyphens, asterixes and colons makes Solr go bananas.
          keywords_dup.gsub!(/-|:/, ' ')

          keywords_dup
        end
    end
  end
end
