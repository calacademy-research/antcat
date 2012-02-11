# coding: UTF-8
require 'snake'
require 'catalog/index_helper'
require 'catalog/browser_helper'

module CatalogHelper
  include Catalog::IndexHelper
  include Catalog::BrowserHelper

  def status_labels
    Formatters::CatalogFormatter.status_labels
  end

  def format_statistics statistics, include_invalid = true
    Formatters::CatalogFormatter.format_statistics statistics, :include_invalid => include_invalid
  end

  def make_catalog_search_results_columns items
    column_count = 3
    items.snake column_count
  end

  def search_selector current_search_type
    select_tag :search_type,
      options_for_select(['matching', 'beginning with', 'containing'], current_search_type || 'beginning with')
  end

  def taxonomic_history taxon
    Formatters::CatalogFormatter.format_taxonomic_history taxon
  end

end
