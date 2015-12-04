# coding: UTF-8
class Exporters::Antweb::Formatter < Formatters::TaxonFormatter
  include Formatters::LinkFormatter
  extend Formatters::LinkFormatter

  $use_ant_web_formatter = true

  def format
    content_tag :div, class: 'antcat_taxon' do
      content = ''.html_safe
      content << statistics(include_invalid: false)
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

  def history_item_body_attributes
    { style: 'font-size: 13px' }
  end

  def self.link_to_taxon taxon # used in Taxt.rb
    link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
  end

end