# coding: UTF-8
require 'snake'

module Catalog::IndexHelper
  def index_column_link rank, taxon, selected_taxon, page_parameters = {}
    if taxon == 'none'
      classes = 'valid'
      classes << ' selected' if taxon == selected_taxon
      if rank == :subfamily
        parameters = "subfamily=none"
        parameters << "&hide_tribes=true" if page_parameters[:hide_tribes]
        link_to "(no subfamily)", "/catalog/index?#{parameters}", :class => classes
      elsif rank == :tribe
        parameters = "subfamily=#{page_parameters[:subfamily].id}&tribe=none"
        link_to "(no tribe)", "/catalog/index?#{parameters}", :class => classes
      end
    else
      label = Formatters::CatalogFormatter.taxon_label taxon
      css_classes = Formatters::CatalogFormatter.taxon_css_classes taxon, :selected => taxon == selected_taxon
      link_to label, index_catalog_path(taxon, page_parameters.merge(rank => taxon)), :class => css_classes
    end
  end

  def hide_link name, selected, page_parameters
    hide_param = "hide_#{name}".to_sym
    link_to 'hide', index_catalog_path(selected, page_parameters.merge(hide_param => true)), :class => :hide
  end

  def show_child_link params, name, selected, page_parameters
    hide_child_param = "hide_#{name}".to_sym
    return unless params[hide_child_param]
    link_to "show #{name}", index_catalog_path(selected, page_parameters.merge(hide_child_param => nil))
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
end
