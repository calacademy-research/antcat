# frozen_string_literal: true

# TODO: Make sure relevant formatters are covered by specs and then call them directly from here.
module TestLinksHelpers
  def author_link author_name
    %(<a href="/authors/#{author_name.author.id}">#{author_name.name}</a>)
  end

  # Taxa.
  def taxon_link taxon
    CatalogFormatter.link_to_taxon(taxon)
  end

  def taxon_link_with_label taxon, label
    CatalogFormatter.link_to_taxon_with_label(taxon, label)
  end

  def taxon_link_with_author_citation taxon
    css_classes = CatalogFormatter.taxon_disco_mode_css(taxon)

    <<~HTML.squish
      <a data-controller="hover-preview"
      data-hover-preview-url-value="/catalog/#{taxon.id}/hover_preview.json"
      class="#{css_classes}"
      href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a> #{taxon.author_citation}
    HTML
  end

  # Protonyms.
  def protonym_link protonym
    CatalogFormatter.link_to_protonym(protonym)
  end

  # References.
  def reference_link reference
    CatalogFormatter.link_to_reference(reference)
  end

  def reference_taxt_link reference
    <<~HTML.squish
      <a data-controller="hover-preview"
      data-hover-preview-url-value="/references/#{reference.id}/hover_preview.json"
      class="taxt-hover-reference"
      href="/references/#{reference.id}">#{reference.key_with_suffixed_year}</a>
    HTML
  end

  def taxon_authorship_link taxon
    reference = taxon.authorship_reference

    <<~HTML.squish
      <a data-controller="hover-preview"
      data-hover-preview-url-value="/references/#{reference.id}/hover_preview.json"
      href="/references/#{reference.id}">#{taxon.author_citation}</a>
    HTML
  end
end
