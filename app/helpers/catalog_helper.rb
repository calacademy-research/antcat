# coding: UTF-8
require 'snake'

module CatalogHelper
  def status_labels
    Formatters::CatalogFormatter.status_labels
  end

  def format_statistics statistics, include_invalid = true
    Formatters::CatalogFormatter.format_statistics statistics, :include_invalid => include_invalid
  end

  def make_catalog_search_results_columns items
    column_count = 5
    items.snake column_count
  end

  def search_selector search_type
    select_tag :st, options_for_select([['matching', 'm'], ['beginning with', 'bw'], ['containing', 'c']], search_type || 'bw')
  end

  def index_column_link rank, taxon, selected_taxon, parent_taxon, parameters = {}
    parameters = parameters.dup
    parameters.delete :id
    parameters.delete :child
    if taxon == 'none'
      parameters[:child] = 'none'
      classes = 'valid'
      classes << ' selected' if taxon == selected_taxon
      if rank == :subfamily
        id_string = ''
        label = '(no subfamily)'
      elsif rank == :tribe
        id_string = "/#{parent_taxon.id}"
        label = '(no tribe)'
      end
    else
      id_string = "/#{taxon.id}"
      label = Formatters::CatalogFormatter.taxon_label taxon
      classes = Formatters::CatalogFormatter.taxon_css_classes taxon, selected: taxon == selected_taxon
    end
    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    link_to label, "/catalog#{id_string}#{parameters_string}", class: classes
  end

  def search_result_link item, parameters
    parameters = parameters.dup
    css_class = item[:id].to_s == parameters[:id] ? 'selected' : nil
    parameters.delete :id
    parameters.delete :child
    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    link_to raw(item[:name]), "/catalog/#{item[:id]}#{parameters_string}", class: css_class
  end

  def hide_link name, selected, parameters
    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    link_to 'hide', "/catalog/hide_#{name}#{parameters_string}"
  end

  def show_child_link name, selected, parameters
    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    link_to "show #{name}", "/catalog/show_#{name}#{parameters_string}"
  end

  def snake_taxon_columns items
    column_count = items.count / 26.0
    css_class = 'taxon_item'
    if column_count < 1
      column_count = 1
    else
      column_count = column_count.ceil
    end
    if column_count >= 3
      column_count = 3
      css_class << ' teensy'
    end
    return items.snake(column_count), css_class
  end

  def creating_taxon_message rank, parent
    "Adding #{rank} to #{parent.name}"
  end

end
