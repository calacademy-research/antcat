# coding: UTF-8
class Exporters::Antweb::Formatter < Formatters::TaxonFormatter
  include Formatters::LinkFormatter
  extend Formatters::LinkFormatter

  def include_invalid; false end
  def expand_references?; false end

  def link_to_other_site
    link_to_antcat @taxon
  end

  def link_to_edit_taxon; end

  def link_to_review_change; end

  # overrides to stub stuff out
  def header
  end

  def history
    return unless @taxon.history_items.present?
    '<p><b>Taxonomic history</b></p>'.html_safe + super
  end

  def homonym_replaced_for taxon
    homonym_replaced = taxon.homonym_replaced
    return '' unless homonym_replaced
    label_and_classes = taxon_label_and_css_classes taxon, :uppercase => true
    span = content_tag('span', label_and_classes[:label], :class => label_and_classes[:css_classes])
    string = %{<p class="taxon_subsection_header">Homonym replaced by #{span}</p>}
    string << %{<div id="#{homonym_replaced.id}">#{homonym_replaced.history}</div>}
    string
  end

  def history_item_body_attributes
    {style: 'font-size: 13px'}
  end

  def self.link_to_antweb_taxon taxon
    return if taxon.kind_of? Family
    return unless Exporters::Antweb::Exporter.exportable? taxon
    url = %{http://www.antweb.org/description.do?}
    url << case taxon
    when Species
      %{name=#{taxon.name.epithet.to_s.downcase}&genus=#{taxon.genus.name.to_s.downcase}&rank=species}
    when Subspecies
      %{name=#{taxon.name.epithets.to_s.downcase}&genus=#{taxon.genus.name.to_s.downcase}&rank=species}
    when Genus
      %{name=#{taxon.name.to_s.downcase}&rank=genus}
    when Subfamily
      %{name=#{taxon.name.to_s.downcase}&rank=subfamily}
    end
    url << %{&project=worldants}
    link_to_external_site 'AntWeb', url.html_safe
  end

  def self.link_to_taxon taxon
    link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
  end

end
