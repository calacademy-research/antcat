# coding: UTF-8
module Catalog::StatisticsFormatter
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::NumberHelper
  extend Formatter

  def format_taxon_statistics taxon, options = {}
    return '' unless taxon
    statistics = taxon.statistics
    return '' unless statistics
    format_statistics statistics, options
  end

  def format_statistics statistics, options = {}
    options.reverse_merge! :include_invalid => true, :include_fossil => true
    return '' unless statistics && statistics.present?
    strings = [:extant, :fossil].inject({}) do |strings, extant_or_fossil|
      extant_or_fossil_statistics = statistics[extant_or_fossil]
      if extant_or_fossil_statistics
        string = [:subfamilies, :genera, :species, :subspecies].inject([]) do |rank_strings, rank|
          string = format_rank_statistics(extant_or_fossil_statistics, rank, options[:include_invalid])
          rank_strings << string if string.present?
          rank_strings
        end.join ', '
        strings[extant_or_fossil] = string
      end
      strings
    end
    strings = if strings[:extant] && strings[:fossil] && options[:include_fossil]
      strings[:extant].insert 0, 'Extant: '
      strings[:fossil].insert 0, 'Fossil: '
      [strings[:extant], strings[:fossil]]
    elsif strings[:extant]
      [strings[:extant]]
    elsif options[:include_fossil]
      ['Fossil: ' + strings[:fossil]]
    else
      []
    end
    strings.map do |string|
      content_tag('p', string, :class => 'taxon_statistics')
    end.join.html_safe
  end

  def format_rank_statistics statistics, rank, include_invalid
    statistics = statistics[rank]
    return unless statistics

    string = ''

    if statistics['valid']
      string << format_rank_status_count(rank, 'valid', statistics['valid'], include_invalid)
      statistics.delete 'valid'
    end

    return string unless include_invalid

    status_strings = statistics.keys.sort_by do |key|
      Status.ordered_statuses.index key
    end.inject([]) do |status_strings, status|
      status_strings << format_rank_status_count(:genera, status, statistics[status])
    end

    if status_strings.present?
      string << ' ' if string.present?
      string << "(#{status_strings.join(', ')})"
    end

    string.present? && string
  end

  def format_rank_status_count rank, status, count, label_statuses = true
    if label_statuses
      count_and_status = pluralize_with_delimiters count, status, Status[status].to_s(status != 'valid' ? :plural : nil)
    else
      count_and_status = number_with_delimiter count
    end
    string = count_and_status
    string << " #{Rank[rank].to_s(count)}" if status == 'valid'
    string
  end

end
