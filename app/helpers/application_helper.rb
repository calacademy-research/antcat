module ApplicationHelper

  def taxon_label_and_css_classes taxon, options = {}
    fossil_symbol = taxon.fossil? ? "&dagger;" : ''
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if options[:selected]
    name = taxon.name.dup
    name.upcase! if options[:uppercase]
    label = fossil_symbol + h(name)
    {:label => label.html_safe, :css_classes => css_classes_for_taxon(taxon, options[:selected])}
  end

  def css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon']
  end

  def taxon_header taxon
    label_and_css_classes = taxon_label_and_css_classes taxon, :uppercase => true
    (taxon.rank.capitalize + ' ' + link_to(label_and_css_classes[:label], browser_taxatry_path(taxon), :class => label_and_css_classes[:css_classes])).html_safe
  end

  def css_classes_for_taxon taxon, selected = false
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if selected
    css_classes = css_classes.sort.join ' '
  end

end
