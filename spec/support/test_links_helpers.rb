# frozen_string_literal: true

module TestLinksHelpers
  def author_link author_name
    %(<a href="/authors/#{author_name.author.id}">#{author_name.name}</a>)
  end

  def taxon_link taxon, label = nil
    css_classes = CatalogFormatter.taxon_disco_mode_css(taxon)
    %(<a class="#{css_classes}" href="/catalog/#{taxon.id}">#{label || taxon.name_with_fossil}</a>)
  end

  def taxon_link_with_author_citation taxon
    css_classes = CatalogFormatter.taxon_disco_mode_css(taxon)
    %(<a class="#{css_classes}" href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a> #{taxon.author_citation})
  end

  def protonym_link protonym
    %(<a class="protonym protonym-hover-preview-link" href="/protonyms/#{protonym.id}">#{protonym.name.name_html}</a>)
  end

  def reference_link reference
    %(<a href="/references/#{reference.id}">#{reference.key_with_suffixed_year}</a>)
  end

  def taxon_authorship_link taxon
    %(<a href="/references/#{taxon.authorship_reference.id}">#{taxon.author_citation}</a>)
  end
end
