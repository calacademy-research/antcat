module TaxatryHelper

  def taxon_link taxon, selected, search_params
    fossil_symbol = taxon.fossil? ? "&dagger;" : ''
    css_classes = [taxon.type.class.to_s.downcase]
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if taxon == selected
    link_to "#{fossil_symbol}#{taxon.name}", taxon_path(taxon, search_params), :class => css_classes.join(' ')
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
    rank_strings.join ', '
  end

  def format_rank_statistics statistics, rank
    statistics = statistics[rank]
    return unless statistics

    string = format_rank_status_count rank, 'valid', statistics['valid']
    statistics.delete 'valid' 

    status_strings = statistics.keys.sort_by do |key|
      ordered_statuses.index key
    end.inject([]) do |status_strings, status|
      status_strings << format_rank_status_count(:genera, status, statistics[status])
    end
    string << " (#{status_strings.join(', ')})" if status_strings.present?
    string
  end

  def format_rank_status_count rank, status, count
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

end
