module TaxatryHelper

  def taxon_link taxon, selected, search_params
    fossil_symbol = taxon.fossil? ? "&dagger;" : ''
    css_classes = [taxon.type.class.to_s.downcase]
    css_classes << taxon.status
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

  def format_taxon_statistics statistics
    "2 valid genera (1 synonym)"
  end

end
