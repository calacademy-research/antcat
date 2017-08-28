class TaxonDecorator::Statistics
  include ActionView::Helpers
  include ActionView::Context
  include ApplicationHelper # For #pluralize_with_delimiters and #count_and_status.

  # TODO: Push include_invalid/include_fossil to the taxa models.
  # This method is cheap, but Taxon#statistics is very slow and it always
  # fetches all statistics and then this method removes invalid/fossil taxa.
  def initialize statistics, include_invalid: true, include_fossil: true
    @statistics = statistics
    @include_invalid = include_invalid
    @include_fossil = include_fossil
  end

  def call
    return '' unless @statistics.present?

    strings = [:extant, :fossil].reduce({}) do |strings, extant_or_fossil|
      extant_or_fossil_statistics = @statistics[extant_or_fossil]
      if extant_or_fossil_statistics
        string = [:subfamilies, :tribes, :genera, :species, :subspecies].reduce([]) do |rank_strings, rank|
          string = rank_statistics(extant_or_fossil_statistics, rank, include_invalid)
          rank_strings << string if string.present?
          rank_strings
        end.join ', '
        strings[extant_or_fossil] = string
      end
      strings
    end

    strings = if strings[:extant] && strings[:fossil] && include_fossil
                strings[:extant].insert 0, 'Extant: '
                strings[:fossil].insert 0, 'Fossil: '
                [strings[:extant], strings[:fossil]]
              elsif strings[:extant]
                [strings[:extant]]
              elsif include_fossil
                ['Fossil: ' + strings[:fossil]]
              else
                []
              end

    strings.map do |string|
      content_tag :p, string
    end.join.html_safe
  end

  private
    attr_reader :include_invalid, :include_fossil

    def rank_statistics statistics, rank, include_invalid
      statistics = statistics[rank]
      return unless statistics

      strings = []
      strings << valid_statistics(statistics, rank, include_invalid)
      strings << invalid_statistics(statistics) if include_invalid

      strings.compact.join ' '
    end

    def valid_statistics statistics, rank, include_invalid
      return unless statistics['valid']

      string = rank_status_count(rank, 'valid', statistics['valid'], include_invalid)
      statistics.delete 'valid'
      string
    end

    def invalid_statistics statistics
      sorted_keys = statistics.keys.sort_by do |key|
        Status.ordered_statuses.index key
      end

      status_strings = sorted_keys.map do |status|
        rank_status_count(:genera, status, statistics[status])
      end

      if status_strings.present?
        "(#{status_strings.join(', ')})"
      else
        nil
      end
    end

    def rank_status_count rank, status, count, label_statuses = true
      count_and_status =
        if label_statuses
          pluralize_with_delimiters count, status, Status[status].to_s(:plural)
        else
          number_with_delimiter count
        end

      if status == 'valid'
        # We must first singularize because rank may already be pluralized.
        count_and_status << " #{rank.to_s.singularize.pluralize(count)}"
      end
      count_and_status
    end
end
