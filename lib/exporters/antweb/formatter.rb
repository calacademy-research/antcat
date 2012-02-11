# coding: UTF-8
class Exporters::Antweb::Formatter

  def self.format_taxonomic_history_for_antweb taxon
    string = taxon.taxonomic_history
    string << format_homonym_replaced_for_antweb(taxon)
    string.html_safe if string
  end

  def self.format_homonym_replaced_for_antweb taxon
    homonym_replaced = taxon.homonym_replaced
    return '' unless homonym_replaced
    label_and_classes = taxon_label_and_css_classes taxon, :uppercase => true
    span = content_tag('span', label_and_classes[:label], :class => label_and_classes[:css_classes])
    string = %{<p class="taxon_subsection_header">Homonym replaced by #{span}</p>}
    string << %{<div id="#{homonym_replaced.id}">#{homonym_replaced.taxonomic_history}</div>}
    string
  end

  def self.format_taxonomic_history_with_statistics_for_antweb taxon, options = {}
    Formatters::CatalogFormatter.format_taxon_statistics(taxon, options) + format_taxonomic_history_for_antweb(taxon)
  end

end
