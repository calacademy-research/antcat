require 'snake'

module TaxatryHelper

  def taxon_link taxon, selected, search_params
    label_and_classes = taxon_label_and_css_classes taxon, :selected => taxon == selected
    link_to label_and_classes[:label], index_taxatry_path(taxon, search_params), :class => label_and_classes[:css_classes]
  end

  def snake_taxon_columns items
    column_count = items.count / 25.0
    css_class = 'taxon_item'
    if column_count < 1
      column_count = 1
    else
      column_count = column_count.ceil
    end
    if column_count >= 4
      column_count = 4
      css_class << ' teensy'
    end
    return items.snake(column_count), css_class
  end

  def make_taxatry_search_results_columns items
    column_count = 3
    items.snake column_count
  end

  def taxon_statistics taxon
    statistics = taxon.statistics
    rank_strings = []
    string = format_rank_statistics(statistics, :genera)
    rank_strings << string if string
    string = format_rank_statistics(statistics, :species)
    rank_strings << string if string
    string = format_rank_statistics(statistics, :subspecies)
    rank_strings << string if string
    rank_strings.join ', '
  end

  def format_rank_statistics statistics, rank
    statistics = statistics[rank]
    return unless statistics

    string = ''

    if statistics['valid']
      string << format_rank_status_count(rank, 'valid', statistics['valid'])
      statistics.delete 'valid'
    end

    status_strings = statistics.keys.sort_by do |key|
      ordered_statuses.index key
    end.inject([]) do |status_strings, status|
      status_strings << format_rank_status_count(:genera, status, statistics[status])
    end

    if status_strings.present?
      string << ' ' if string.present?
      string << "(#{status_strings.join(', ')})"
    end

    string.present? && string
  end

  def format_rank_status_count rank, status, count
    rank = :genus if rank == :genera and count == 1
    count_and_status = pluralize count, status, status == 'valid' ? status : status_plural(status)
    string = count_and_status
    string << " #{rank.to_s}" if status == 'valid'
    string
  end

  def status_plural status
    statuses[status]
  end

  def statuses
    @statuses || begin
      @statuses = ActiveSupport::OrderedHash.new
      @statuses['synonym'] = 'synonyms'
      @statuses['homonym'] = 'homonyms'
      @statuses['unavailable'] = 'unavailable'
      @statuses['unidentifiable'] = 'unidentifiable'
      @statuses['excluded'] = 'excluded'
      @statuses['unresolved homonym'] = 'unresolved homonyms'
      @statuses['nomen nudum'] = 'nomina nuda'
      @statuses
    end
  end

  def ordered_statuses
    statuses.keys
  end

  def make_index_groups taxa, max_row_count, abbreviated_length
    items_per_row = (taxa.count.to_f / max_row_count).ceil
    return [] if items_per_row.zero?
    taxa.sort_by(&:name).in_groups_of(items_per_row, false).inject([]) do |groups, group|
      result = {:id => group.first.id}
      if group.size > 1
        result[:css_classes] = css_classes_for_rank(group.first).join ' '
        result[:label] = "#{group.first.name[0, abbreviated_length]}-#{group.last.name[0, abbreviated_length]}"
      else
        result.merge! taxon_label_and_css_classes group.first
      end
      groups << result
    end
  end

end
