# frozen_string_literal: true

module References
  class FulltextSearchQuery
    include Service

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      freetext: '', title: nil, author: nil, year: nil, start_year: nil, end_year: nil,
      doi: nil, reference_type: nil, page: 1, per_page: 30
    )
      @freetext = freetext
      # Hyphens, asterixes and colons makes Solr go bananas.
      @title = title.dup.gsub(/-|:|\*/, ' ') if title
      @author = author.dup.gsub(/-|:/, ' ') if author
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

      attr_reader :freetext, :title, :author, :year, :start_year, :end_year, :doi,
        :reference_type, :page, :per_page

      def fulltext_search
        Reference.search(include: [:document]) do # rubocop:disable Metrics/BlockLength
          keywords normalized_freetext

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

          # TODO: Probably support `:book` and `:article`.
          case reference_type
          when 'nested' then with :type, 'NestedReference'
          end

          paginate page: page, per_page: per_page

          order_by :score, :desc
          order_by :author_names_string, :desc
          order_by :citation_year, :asc
        end.results
      end

      # TODO: This is partially duplicated in `References::FulltextSearchLightQuery`.
      def normalized_freetext
        freetext_dup = freetext.dup

        # TODO: Very ugly to make some queries work. Fix in Solr.
        substrings_to_remove = ['<i>', '</i>', '\*'] # Titles may contain these.
        substrings_to_remove.each { |substring| freetext_dup.gsub!(/#{substring}/, '') }

        # Hyphens, asterixes and colons makes Solr go bananas.
        freetext_dup.gsub!(/-|:/, ' ')

        freetext_dup
      end
  end
end