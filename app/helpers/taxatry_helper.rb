module TaxatryHelper

  def taxon_link taxon, selected, search_params
    content_tag :div, :class => 'taxon' do
      fossil_symbol = taxon.fossil? ? "&dagger;" : ''
      css_classes = [taxon.type.class.to_s.downcase]
      css_classes << taxon.status
      css_classes << 'selected' if taxon == selected
      link_to "#{fossil_symbol}#{taxon.name}", taxon_path(taxon, search_params), :class => css_classes.join(' ')
    end
  end

  def make_columns items
    column_count = items.count / 25.0
    css_class = ''
    if column_count < 1
      column_count = 1
    else
      column_count = column_count.ceil
    end
    if column_count >= 4
      column_count = 4
      css_class = 'teensy'
    end
    return items.snake(column_count), css_class
  end

end
