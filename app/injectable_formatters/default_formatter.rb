# frozen_string_literal: true

# TODO: Rename to `CatalogFormatter`.
module DefaultFormatter
  module_function

  # TODO: Move `Taxon#link_to_taxon` here.
  def link_to_taxon taxon
    taxon.link_to_taxon
  end

  def link_to_taxon_with_label taxon, label
    %(<a class="#{disco_mode_css(taxon)}" href="/catalog/#{taxon.id}">#{label}</a>).html_safe
  end

  def disco_mode_css taxon
    css_classes = [taxon.status.tr(' ', '_')]
    css_classes << ['unresolved-homonym'] if taxon.unresolved_homonym?
    css_classes.join(' ')
  end
end
