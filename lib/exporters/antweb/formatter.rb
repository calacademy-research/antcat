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

  def format
    content_tag :div, class: 'antcat_taxon' do
      content = ''.html_safe
      content << statistics(include_invalid: include_invalid)
      content << genus_species_header_notes_taxt
      content << headline
      content << history
      content << child_lists
      content << references
      content
    end
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

  def self.link_to_taxon taxon
    link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
  end

end
