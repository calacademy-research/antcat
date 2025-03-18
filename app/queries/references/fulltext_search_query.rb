# frozen_string_literal: true

module References
  class FulltextSearchQuery
    include Service

    # Hyphens and colons makes Solr go bananas.
    UNFRIENDLY_SOLR_CHARACTERS_REGEX = /-|:/
    FREETEXT_SUBSTRINGS_TO_REMOVE = ['<i>', '</i>', '\*'] # Titles may contain these.

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

    def call
      search_results
    end

    private

      attr_reader :freetext, :title, :author, :year, :start_year, :end_year, :doi,
        :reference_type, :page, :per_page

      def search_results
        Reference.solr_search(include: [:document]) do |solr|
          solr.keywords(normalized_freetext)

          if title
            solr.keywords(title) do
              fields(:title)
            end
          end

          if author
            solr.keywords(author) do
              fields(:author_names_string)
            end
          end

          if year
            solr.with(:year).equal_to(year)
          end

          if start_year && end_year
            solr.with(:year).between(start_year..end_year)
          end

          if doi
            solr.with(:doi).equal_to(doi)
          end

          # TODO: Probably support `:book` and `:article`.
          case reference_type
          when 'nested' then solr.with(:type, 'NestedReference')
          end

          solr.paginate(page: page, per_page: per_page)

          solr.order_by(:score, :desc)
          solr.order_by(:author_names_string, :desc)
          solr.order_by(:suffixed_year, :asc)
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
