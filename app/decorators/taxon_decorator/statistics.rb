class TaxonDecorator::Statistics
  include ActionView::Helpers
  include ActionView::Context
  include Service
  include ApplicationHelper # For `#pluralize_with_delimiters` and `#number_with_delimiter`.

  def initialize statistics
    @statistics = statistics
  end

  def call
    return '' if @statistics.blank?

    strings = [:extant, :fossil].each_with_object({}) do |extant_or_fossil, memo|
      extant_or_fossil_stats = @statistics[extant_or_fossil]

      next unless extant_or_fossil_stats
      string = [:subfamilies, :tribes, :genera, :species, :subspecies].reduce([]) do |rank_strings, rank|
        rank_strings << rank_statistics(extant_or_fossil_stats[rank], rank)
      end.compact.join(', ')
      memo[extant_or_fossil] = string
    end

    strings = if strings[:extant] && strings[:fossil]
                strings[:extant].insert 0, 'Extant: '
                strings[:fossil].insert 0, 'Fossil: '
                [strings[:extant], strings[:fossil]]
              elsif strings[:extant]
                [strings[:extant]]
              else
                ['Fossil: ' + strings[:fossil]]
              end

    strings.map do |string|
      content_tag :p, string
    end.join.html_safe
  end

  private

    def rank_statistics rank_stats, rank
      return unless rank_stats

      valid_string = valid_statistics rank_stats.delete('valid'), rank

      invalid_string = invalid_statistics rank_stats
      if invalid_string && valid_string.blank?
        valid_string = "0 valid #{rank}"
      end

      [valid_string, invalid_string].compact.join ' '
    end

    def valid_statistics valid_rank_stats, rank
      return unless valid_rank_stats
      rank_status_count(rank, 'valid', valid_rank_stats)
    end

    def invalid_statistics rank_stats
      sorted_keys = rank_stats.keys.sort_by do |key|
        Status::STATUSES.index key
      end

      status_strings = sorted_keys.map do |status|
        rank_status_count(:genera, status, rank_stats[status])
      end

      if status_strings.present?
        "(#{status_strings.join(', ')})"
      end
    end

    def rank_status_count rank, status, count
      count_and_status = pluralize_with_delimiters count, status, Status.plural(status)

      if status == Status::VALID
        # We must first singularize because rank may already be pluralized.
        count_and_status << " #{rank.to_s.singularize.pluralize(count)}"
      end
      count_and_status
    end
end
