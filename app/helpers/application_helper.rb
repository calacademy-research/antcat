module ApplicationHelper

  def taxon_label_and_css_classes taxon, selected = false
    fossil_symbol = taxon.fossil? ? "&dagger;" : ''
    css_classes = [taxon.type.downcase]
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if taxon == selected
    label = fossil_symbol + h(taxon.name)
    {:label => label.html_safe, :css_classes => css_classes}
  end

end
