# frozen_string_literal: true

module Taxa
  module Statistics
    class FormatStatistics
      include ActionView::Context # For `#content_tag`.
      include ActionView::Helpers::TagHelper # For `#content_tag`.
      include ActionView::Helpers::NumberHelper # For `#number_with_delimiter`.
      include Service

      def initialize statistics
        @statistics = statistics
      end

      def call
        return  if statistics.blank?

        statistics.slice(:extant, :fossil).map do |extant_or_fossil, extant_or_fossil_stats|
          stats = extant_or_fossil_stats.map do |rank, rank_stats|
            [
              valid_statistics(rank_stats.delete('valid'), rank),
              invalid_statistics(rank_stats)
            ].compact.join(' ')
          end

          content_tag :p, "#{extant_or_fossil.capitalize}: " + stats.join(', ')
        end.join.html_safe
      end

      private

        attr_reader :statistics

        def valid_statistics count, rank
          count ||= 0
          "#{number_with_delimiter(count)} valid #{rank.to_s.singularize.pluralize(count)}"
        end

        def invalid_statistics rank_stats
          return if rank_stats.blank?

          sorted_keys = rank_stats.keys.sort_by do |key|
            Status::STATUSES.index key
          end

          status_strings = sorted_keys.map do |status|
            count = rank_stats[status]
            PluralizeWithDelimiters[count, status, Status.plural(status)]
          end.join(', ')

          "(#{status_strings})"
        end
    end
  end
end
