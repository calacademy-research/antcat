module TaxatryHelper

  def taxon_link taxon, selected
    content_tag :div, :class => 'taxon' do
      fossil_symbol = taxon.fossil? ? "&dagger;" : ''
      css_classes = [taxon.type.class.to_s.downcase]
      css_classes << taxon.status
      css_classes << 'selected' if taxon == selected
      link_to "#{fossil_symbol}#{taxon.name}", taxon_path(taxon), :class => css_classes.join(' ')
    end
  end

end
