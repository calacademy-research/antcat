module TaxonomicHistoryHelper

  def taxonomic_history taxon
    string = taxon.taxonomic_history
    homonym_replaced = taxon.homonym_replaced
    if homonym_replaced
      label_and_classes = taxon_label_and_css_classes taxon, :uppercase => true
      span = content_tag('span', label_and_classes[:label], :class => label_and_classes[:css_classes])
      string << %{<p class="taxon_subsection_header">Homonym replaced by #{span}</p>}
      string << homonym_replaced.taxonomic_history
    end
    string
  end

end
