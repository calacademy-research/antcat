require 'snake'

module CatalogHelper

  def taxon_link taxon, selected, url_parameters
    if taxon =~ /^no_/
      classes = 'valid'
      classes << ' selected' if taxon == selected
      link_to '(incertae sedis)', index_catalog_path(taxon, url_parameters), :class => classes
    else
      label_and_classes = CatalogFormatter.taxon_label_and_css_classes taxon, :selected => taxon == selected
      link_to label_and_classes[:label], index_catalog_path(taxon, url_parameters), :class => label_and_classes[:css_classes]
    end
  end

  def hide_link name, selected, url_parameters
    hide_param = "hide_#{name}".to_sym
    link_to 'hide', index_catalog_path(selected, url_parameters.merge(hide_param => true)), :class => :hide
  end

  def show_child_link params, name, selected, url_parameters
    hide_child_param = "hide_#{name}".to_sym
    return unless params[hide_child_param]
    link_to "show #{name}", index_catalog_path(selected, url_parameters.merge(hide_child_param => nil))
  end

  def snake_taxon_columns items
    column_count = items.count / 26.0
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

  def make_catalog_search_results_columns items
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
    status_labels[status][:plural]
  end

  def status_labels
    @status_labels || begin
      @status_labels = ActiveSupport::OrderedHash.new
      @status_labels['synonym']             = {:singular => 'synonym', :plural => 'synonyms'}
      @status_labels['homonym']             = {:singular => 'homonym', :plural => 'homonyms'}
      @status_labels['unavailable']         = {:singular => 'unavailable', :plural => 'unavailable'}
      @status_labels['unidentifiable']      = {:singular => 'unidentifiable', :plural => 'unidentifiable'}
      @status_labels['excluded']            = {:singular => 'excluded', :plural => 'excluded'}
      @status_labels['unresolved homonym']  = {:singular => 'unresolved homonym', :plural => 'unresolved homonyms'}
      @status_labels['recombined']          = {:singular => 'transferred out of this genus', :plural => 'transferred out of this genus'}
      @status_labels['nomen nudum']         = {:singular => 'nomen nudum', :plural => 'nomina nuda'}
      @status_labels
    end
  end

  def ordered_statuses
    status_labels.keys
  end

  def make_index_groups taxa, max_row_count, abbreviated_length
    items_per_row = (taxa.count.to_f / max_row_count).ceil
    return [] if items_per_row.zero?
    groups = taxa.sort_by(&:name).in_groups_of(items_per_row, false)
    any_groups_with_more_than_one_member = false
    groups.inject([]) do |label_groups, group|
      result = {:id => group.first.id}
      label_and_classes = CatalogFormatter.taxon_label_and_css_classes group.first
      any_groups_with_more_than_one_member ||= group.size > 1
      if any_groups_with_more_than_one_member
        if group.size > 1
          result[:label] = "#{group.first.name[0, abbreviated_length]}-#{group.last.name[0, abbreviated_length]}"
          result[:css_classes] = CatalogFormatter.css_classes_for_rank(group.first).join ' '
        else
          result.merge! label_and_classes
          result[:css_classes] = CatalogFormatter.css_classes_for_rank(group.first).join ' '
        end
      else
        result.merge! label_and_classes
      end
      label_groups << result
    end
  end

  def taxon_header taxon, options = {}
    label_and_css_classes = CatalogFormatter.taxon_label_and_css_classes taxon, :uppercase => true
    if options[:link]
      (taxon.rank.capitalize + ' ' + link_to(label_and_css_classes[:label], browser_catalog_path(taxon, options[:search_params]), :class => label_and_css_classes[:css_classes])).html_safe
    else
      (taxon.rank.capitalize + ' ' + content_tag('span', label_and_css_classes[:label], :class => label_and_css_classes[:css_classes])).html_safe
    end
  end

  def search_selector current_search_type
    select_tag :search_type,
      options_for_select(['matching', 'beginning with', 'containing'], current_search_type || 'beginning with')
  end

end
