# Requires that the client have:
#   :type, :principal_author_last_name_cache, :title
#
# Compares using these fields:
#   :type, :principal_author_last_name_cache, :title, :year,
#   :pagination, :series_volume_issue
#
# Ignores:
#   :journal, :place, :publisher

module References
  class ReferenceSimilarity
    include Service

    def initialize lhs_reference, rhs_reference
      @lhs = lhs_reference
      @rhs = rhs_reference
    end

    def call
      similarity
    end

    private

      attr_reader :lhs, :rhs
      delegate :type, :principal_author_last_name_cache, :title, :year, :pagination,
        :series_volume_issue, to: :lhs

      def similarity
        return 0.00 unless type == rhs.type
        return 0.00 unless normalize_author(principal_author_last_name_cache) == normalize_author(rhs.principal_author_last_name_cache)

        result = match_title || match_article || match_book
        year_matches = year_matches?
        pagination_matches = pagination_matches?

        case
        when !result && !year_matches      then 0.00
        when !result && year_matches       then 0.10
        when result && !year_matches       then result - 0.50
        when result && !pagination_matches then result - 0.01
        else                                    result
        end
      end

      def year_matches?
        return unless rhs.year && year
        (rhs.year.to_i - year.to_i).abs <= 1
      end

      def pagination_matches?
        rhs.pagination == pagination
      end

      def match_title
        other_title = rhs.title.dup
        title = lhs.title.dup
        return 1.00 if normalize_title!(other_title) == normalize_title!(title)

        remove_bracketed_phrases! other_title
        remove_bracketed_phrases! title
        return unless other_title.present? && title.present?
        return 0.95 if other_title == title

        return 0.94 if replace_roman_numerals!(other_title) == replace_roman_numerals!(title)
        return 1.00 if remove_punctuation!(other_title) == remove_punctuation!(title)
      end

      # NOTE using `#type` to make the service more general.
      def match_article
        return unless rhs.type == 'ArticleReference' && type == 'ArticleReference'
        return unless rhs.series_volume_issue.present? && series_volume_issue.present?
        return unless rhs.pagination.present? && pagination.present? && rhs.pagination == pagination

        return 0.90 if normalize_series_volume_issue(rhs.series_volume_issue) ==
            normalize_series_volume_issue(series_volume_issue)
      end

      # NOTE using `#type` to make the service more general.
      def match_book
        return unless rhs.type == 'BookReference' && type == 'BookReference'
        return unless rhs.pagination.present? && pagination.present?
        return 0.80 if rhs.pagination == pagination
      end

      def normalize_series_volume_issue string
        string = string.dup
        remove_year_in_parentheses! string
        remove_no! string
        replace_punctuation_with_space! string
        string
      end

      def replace_punctuation_with_space! string
        string.gsub! /[[:punct:]]/, ' '
        string.squish!
      end

      def remove_year_in_parentheses! string
        string.gsub! /\(\d{4}\)$/, ''
      end

      def remove_no! string
        string.gsub! /\(No. (\d+)\)$/, '(\1)'
      end

      def normalize_title! string
        remove_parenthesized_taxon_names! string
        string.replace ActiveSupport::Inflector.transliterate string.downcase
        string
      end

      def remove_punctuation! string
        string.gsub! /[^\w\s]/, ''
        string
      end

      def normalize_author string
        ActiveSupport::Inflector.transliterate string.downcase
      end

      def remove_parenthesized_taxon_names! string
        match = string.match(/ \(.+?\)/)
        return string unless match

        possible_taxon_names = match.to_s.strip.gsub(/[(),:]/, '').split(/[ ]/)
        any_taxon_names = possible_taxon_names.any? do |word|
          ['Formicidae', 'Hymenoptera'].include? word
        end
        string[match.begin(0)..(match.end(0) - 1)] = '' if any_taxon_names
        string
      end

      def remove_bracketed_phrases! string
        string.gsub!(/\s?\[.*?\]\s?/, ' ')
        string.strip!
        string
      end

      def replace_roman_numerals! string
        roman_numerals = [
          ['i',  1], ['ii',  2], ['iii',  3], ['iv', 4], ['v', 5],
          ['vi', 6], ['vii', 7], ['viii', 8], ['ix', 9], ['x', 10]
        ]

        roman_numerals.each do |roman, arabic|
          string.gsub! /\b#{roman}\b/, arabic.to_s
        end
        string
      end
  end
end
