class TaxatryFormatter
  extend ERB::Util
  extend ActionView::Helpers::TagHelper

  def self.format_taxonomic_history taxon
    string = taxon.taxonomic_history
    homonym_replaced = taxon.homonym_replaced
    if homonym_replaced
      label_and_classes = taxon_label_and_css_classes taxon, :uppercase => true
      span = content_tag('span', label_and_classes[:label], :class => label_and_classes[:css_classes])
      string << %{<p class="taxon_subsection_header">Homonym replaced by #{span}</p>}
      string << %{<div id="#{homonym_replaced.id}">#{homonym_replaced.taxonomic_history}</div>}
    end
    string
  end

  def self.taxon_label_and_css_classes taxon, options = {}
    fossil_symbol = taxon.fossil? ? "&dagger;" : ''
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if options[:selected]
    name = taxon.name.dup
    name.upcase! if options[:uppercase]
    label = fossil_symbol + h(name)
    {:label => label.html_safe, :css_classes => css_classes_for_taxon(taxon, options[:selected])}
  end

  def self.css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon']
  end

  private
  def self.css_classes_for_taxon taxon, selected = false
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if selected
    css_classes = css_classes.sort.join ' '
  end

end
