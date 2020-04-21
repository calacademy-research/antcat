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
      @lhs = References::ComparableReference.new(left_hand_side_reference)
      @rhs = References::ComparableReference.new(right_hand_side_reference)
    end

    def call
      similarity
    end

    private

      attr_reader :lhs, :rhs

      def similarity
        return 0.00 unless lhs.type == rhs.type
        return 0.00 unless lhs.normalized_author == rhs.normalized_author

        result = match_title || match_article || match_book

        if !result && !year_matches?         then 0.00
        elsif !result && year_matches?       then 0.10
        elsif result && !year_matches?       then result - 0.50
        elsif result && !pagination_matches? then result - 0.01
        else result
        end
      end

      def year_matches?
        @_year_matches ||= (rhs.year.to_i - lhs.year.to_i).abs <= 1
      end

      def pagination_matches?
        rhs.pagination == lhs.pagination
      end

      def match_title
        title = lhs.normalized_title
        other_title = rhs.normalized_title
        return 1.00 if other_title == title

        title = lhs.title_without_bracketed_phrases!
        other_title = rhs.title_without_bracketed_phrases!
        return unless other_title.present? && title.present?
        return 0.95 if other_title == title

        title = lhs.title_with_replaced_roman_numerals!
        other_title = rhs.title_with_replaced_roman_numerals!
        return 0.94 if other_title == title

        return 1.00 if rhs.title_with_removed_punctuation == lhs.title_with_removed_punctuation
      end

      def match_article
        return unless rhs.type == 'ArticleReference' && lhs.type == 'ArticleReference'
        return unless rhs.series_volume_issue.present? && lhs.series_volume_issue.present?
        return unless rhs.pagination.present? && lhs.pagination.present? && rhs.pagination == lhs.pagination

        return 0.90 if rhs.normalized_series_volume_issue == lhs.normalized_series_volume_issue
      end

      def match_book
        return unless rhs.type == 'BookReference' && lhs.type == 'BookReference'
        return unless rhs.pagination.present? && lhs.pagination.present?
        return 0.80 if rhs.pagination == lhs.pagination
      end
  end
end
