# coding: UTF-8
require 'snake'

module CatalogHelper

  def taxon_link rank, taxon, selected_taxon, column_selections = {}

    if rank == :subfamily && taxon == 'none'
      classes = 'valid'
      classes << ' selected' if taxon == selected_taxon
      link_to "(no subfamily)", "/catalog/index?subfamily=none", :class => classes

    else
      label_and_classes = CatalogFormatter.taxon_label_and_css_classes taxon,
        :selected => taxon == selected_taxon
      link_to label_and_classes[:label], index_catalog_path(taxon, column_selections.merge(rank => taxon)),
        :class => label_and_classes[:css_classes]

    end
    #if taxon =~ /^no_/
      #classes = 'valid'
      #classes << ' selected' if taxon == selected
      #link_to "(#{taxon.gsub(/_/, ' ')})", index_catalog_path(taxon, column_selections), :class => classes
    #else
      #label_and_classes = CatalogFormatter.taxon_label_and_css_classes taxon, :selected => taxon == selected
      #link_to label_and_classes[:label], index_catalog_path(taxon, column_selections), :class => label_and_classes[:css_classes]
    #end
  end

  def hide_link name, selected, column_selections
    hide_param = "hide_#{name}".to_sym
    link_to 'hide', index_catalog_path(selected, column_selections.merge(hide_param => true)), :class => :hide
  end

  def show_child_link params, name, selected, column_selections
    hide_child_param = "hide_#{name}".to_sym
    return unless params[hide_child_param]
    link_to "show #{name}", index_catalog_path(selected, column_selections.merge(hide_child_param => nil))
  end

  def status_labels
    CatalogFormatter.status_labels
  end

  def format_statistics statistics, include_invalid = true
    CatalogFormatter.format_statistics statistics, :include_invalid => include_invalid
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
