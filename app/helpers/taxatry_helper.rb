module TaxatryHelper

  def taxon_link taxon, selected
    css_classes = ['taxon']
    css_classes << taxon.type.class.to_s.downcase
    css_classes << taxon.status
    css_classes << 'selected' if taxon == selected
    content_tag :div, :class => css_classes.join(' ') do
      fossil_symbol = taxon.fossil? ? "&dagger;" : ''
      link_to "#{fossil_symbol}#{taxon.name}", taxon_path(taxon)
    end
  end

end
