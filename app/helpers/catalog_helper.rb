module CatalogHelper
  def taxon_label_span taxon
    content_tag :span, class: css_classes_for_rank(taxon) do
      taxon_label(taxon).html_safe
    end
  end

  def taxon_label taxon
    taxon.name.epithet_with_fossil_html taxon.fossil?
  end

  def protonym_label protonym
    protonym.name.protonym_with_fossil_html protonym.fossil
  end

  def css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon', 'name'].sort
  end

  private
    def css_classes_for_status taxon
      css_classes = []
      css_classes << taxon.status.downcase.gsub(/ /, '_')
      css_classes << 'nomen_nudum' if taxon.nomen_nudum?
      css_classes << 'collective_group_name' if taxon.collective_group_name?
      css_classes
    end
end
