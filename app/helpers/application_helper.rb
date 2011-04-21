module ApplicationHelper

  def taxon_label_and_css_classes taxon, selected = false
    fossil_symbol = taxon.fossil? ? "&dagger;" : ''
    css_classes = taxon_rank_css_classes taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if selected
    label = fossil_symbol + h(taxon.name)
    {:label => label.html_safe, :css_classes => css_classes.sort.join(' ')}
  end

  def taxon_rank_css_classes taxon
    [taxon.type.downcase, 'taxon']
  end

end
