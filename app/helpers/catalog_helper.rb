# coding: UTF-8
require 'snake'

module CatalogHelper
  require 'catalog/browser_helper'

  def taxon_link taxon, selected, url_parameters
    if taxon =~ /^no_/
      classes = 'valid'
      classes << ' selected' if taxon == selected
      link_to "(#{taxon.gsub(/_/, ' ')})", index_catalog_path(taxon, url_parameters), :class => classes
    else
      label_and_classes = Formatters::CatalogFormatter.taxon_label_and_css_classes taxon, :selected => taxon == selected
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

  def status_labels
    Formatters::CatalogFormatter.status_labels
  end

  def format_statistics statistics, include_invalid = true
    Formatters::CatalogFormatter.format_statistics statistics, :include_invalid => include_invalid
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

  def search_selector current_search_type
    select_tag :search_type,
      options_for_select(['matching', 'beginning with', 'containing'], current_search_type || 'beginning with')
  end

end
