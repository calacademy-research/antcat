# frozen_string_literal: true

module References
  class FulltextSearchQuery
    include Service

    # Hyphens and colons makes Solr go bananas.
    UNFRIENDLY_SOLR_CHARACTERS_REGEX = /-|:/
    FREETEXT_SUBSTRINGS_TO_REMOVE = ['<i>', '</i>', '\*'] # Titles may contain these.

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      freetext: '', title: nil, author: nil, year: nil, start_year: nil, end_year: nil,
      doi: nil, reference_type: nil, page: 1, per_page: 30
    )
      @freetext = freetext
      @title = title.dup.gsub(UNFRIENDLY_SOLR_CHARACTERS_REGEX, ' ').tr('*', ' ') if title # Asterixes too.
      @author = author.dup.gsub(UNFRIENDLY_SOLR_CHARACTERS_REGEX, ' ') if author
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
      search_results
    end

    private

      attr_reader :freetext, :title, :author, :year, :start_year, :end_year, :doi,
        :reference_type, :page, :per_page

      def search_results
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
          order_by :suffixed_year, :asc
        end.results
      end

      def normalized_freetext
        freetext_dup = freetext.dup

        # TODO: Very ugly to make some queries work. Fix in Solr.
        FREETEXT_SUBSTRINGS_TO_REMOVE.each { |substring| freetext_dup.gsub!(/#{substring}/, '') }
        freetext_dup.gsub!(UNFRIENDLY_SOLR_CHARACTERS_REGEX, ' ')
        freetext_dup
      end
  end
end
