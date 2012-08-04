# coding: UTF-8
class Exporters::Antweb::Formatter < Formatters::TaxonFormatter

  def include_invalid; false end

  def header
  end

  def protonym_name protonym
    ('<b>' + super + '</b>').html_safe
  end

  def history
    return unless @taxon.taxonomic_history_items.present?
    '<p><b>Taxonomic history</b></p>'.html_safe + super
  end

  def reference_link reference
    reference.key.to_link @user, expand: false
  end

  def homonym_replaced_for taxon
    homonym_replaced = taxon.homonym_replaced
    return '' unless homonym_replaced
    label_and_classes = taxon_label_and_css_classes taxon, :uppercase => true
    span = content_tag('span', label_and_classes[:label], :class => label_and_classes[:css_classes])
    string = %{<p class="taxon_subsection_header">Homonym replaced by #{span}</p>}
    string << %{<div id="#{homonym_replaced.id}">#{homonym_replaced.taxonomic_history}</div>}
    string
  end

end
