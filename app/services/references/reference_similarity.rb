# frozen_string_literal: true

module References
  class ReferenceSimilarity
    include Service

    def initialize left_hand_side_reference, right_hand_side_reference
      @lhs = References::ComparableReference.new(left_hand_side_reference)
      @rhs = References::ComparableReference.new(right_hand_side_reference)
    end

    def call
      return 0.00 unless comparable?
      return 0.001 unless results

      results - results_penalty
    end

    private

      attr_reader :lhs, :rhs

      def comparable?
        lhs.type == rhs.type && lhs.normalized_author == rhs.normalized_author
      end

      def results
        @_results ||= match_title || match_article || match_book
      end

      def results_penalty
        penalty = 0.0
        penalty += 0.50 unless year_matches?
        penalty += 0.01 unless pagination_matches?
        penalty
      end

      def year_matches?
        (lhs.year.to_i - rhs.year.to_i).abs <= 1
      end

      def pagination_matches?
        lhs.pagination == rhs.pagination
      end

      def match_title
        return 1.00 if lhs.normalized_title == rhs.normalized_title

        lhs_title = lhs.title_without_bracketed_phrases!
        rhs_title = rhs.title_without_bracketed_phrases!
        return unless lhs_title.present? && rhs_title.present?
        return 0.95 if lhs_title == rhs_title

        return 0.94 if lhs.title_with_replaced_roman_numerals! == rhs.title_with_replaced_roman_numerals!
        return 1.00 if lhs.title_with_removed_punctuation == rhs.title_with_removed_punctuation
      end

      def match_article
        return unless lhs.type == 'ArticleReference' && rhs.type == 'ArticleReference'
        return unless lhs.series_volume_issue.present? && rhs.series_volume_issue.present?
        return unless lhs.pagination.present? && pagination_matches?

        return 0.90 if lhs.normalized_series_volume_issue == rhs.normalized_series_volume_issue
      end

      def match_book
        return unless lhs.type == 'BookReference' && rhs.type == 'BookReference'
        return unless lhs.pagination.present? && rhs.pagination.present?
        return 0.80 if pagination_matches?
      end
  end
end
