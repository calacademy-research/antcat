# frozen_string_literal: true

# TODO: Use Solr or Elasticsearch instead of this class.

# Requires that the client have:
#   :type, :author_names, :title
#
# Compares using these fields:
#   :type, `author_names.first&.last_name`, :title, :year,
#   :pagination, :series_volume_issue
#
# Ignores:
#   :journal, :publisher

module References
  class ReferenceSimilarity
    include Service

    def initialize left_hand_side_reference, right_hand_side_reference
      @lhs = left_hand_side_reference
      @rhs = right_hand_side_reference
      @lhs_comparable = References::ComparableReference.new(left_hand_side_reference)
      @rhs_comparable = References::ComparableReference.new(right_hand_side_reference)
    end

    def call
      similarity
    end

    private

      attr_reader :lhs, :rhs, :lhs_comparable, :rhs_comparable

      delegate :type, :title, :year, :pagination, :series_volume_issue, to: :lhs, private: true

      def similarity
        return 0.00 unless type == rhs.type
        return 0.00 unless lhs_comparable.normalized_author == rhs_comparable.normalized_author

        result = match_title || match_article || match_book

        if !result && !year_matches?         then 0.00
        elsif !result && year_matches?       then 0.10
        elsif result && !year_matches?       then result - 0.50
        elsif result && !pagination_matches? then result - 0.01
        else result
        end
      end

      def year_matches?
        @_year_matches ||= (rhs.year.to_i - year.to_i).abs <= 1
      end

      def pagination_matches?
        rhs.pagination == pagination
      end

      def match_title
        title = lhs_comparable.normalized_title
        other_title = rhs_comparable.normalized_title
        return 1.00 if other_title == title

        title = lhs_comparable.title_without_bracketed_phrases!
        other_title = rhs_comparable.title_without_bracketed_phrases!
        return unless other_title.present? && title.present?
        return 0.95 if other_title == title

        title = lhs_comparable.title_with_replaced_roman_numerals!
        other_title = rhs_comparable.title_with_replaced_roman_numerals!
        return 0.94 if other_title == title

        return 1.00 if rhs_comparable.title_with_removed_punctuation == lhs_comparable.title_with_removed_punctuation
      end

      def match_article
        return unless rhs.type == 'ArticleReference' && type == 'ArticleReference'
        return unless rhs.series_volume_issue.present? && series_volume_issue.present?
        return unless rhs.pagination.present? && pagination.present? && rhs.pagination == pagination

        return 0.90 if normalize_series_volume_issue(rhs.series_volume_issue) ==
          normalize_series_volume_issue(series_volume_issue)
      end

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
        string.gsub!(/[[:punct:]]/, ' ')
        string.squish!
      end

      def remove_year_in_parentheses! string
        string.gsub!(/\(\d{4}\)$/, '')
      end

      def remove_no! string
        string.gsub!(/\(No. (\d+)\)$/, '(\1)')
      end
  end
end
