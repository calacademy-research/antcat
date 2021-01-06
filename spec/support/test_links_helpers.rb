# frozen_string_literal: true

# TODO: Cleanup methods/names.

module TestLinksHelpers
  def author_link author_name
    %(<a href="/authors/#{author_name.author.id}">#{author_name.name}</a>)
  end

  def taxon_link taxon, label = nil
    css_classes = CatalogFormatter.taxon_disco_mode_css(taxon)
    %(<a v-hover-taxon="#{taxon.id}" class="#{css_classes}" href="/catalog/#{taxon.id}">#{label || taxon.name_with_fossil}</a>)
  end

  def taxon_link_with_author_citation taxon
    css_classes = CatalogFormatter.taxon_disco_mode_css(taxon)
    %(<a v-hover-taxon="#{taxon.id}" class="#{css_classes}" href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a> #{taxon.author_citation})
  end

  def protonym_link protonym
    %(<a v-hover-protonym="#{protonym.id}" class="protonym" href="/protonyms/#{protonym.id}">#{protonym.name.name_html}</a>)
  end

  def reference_link reference
    %(<a v-hover-reference="#{reference.id}" href="/references/#{reference.id}">#{reference.key_with_suffixed_year}</a>)
  end

  # rubocop:disable Layout/LineLength
  def reference_taxt_link reference
    %(<a v-hover-reference="#{reference.id}" class="taxt-hover-reference" href="/references/#{reference.id}">#{reference.key_with_suffixed_year}</a>)
  end
  # rubocop:enable Layout/LineLength

  def taxon_authorship_link taxon
    reference = taxon.authorship_reference
    %(<a v-hover-reference="#{reference.id}" href="/references/#{reference.id}">#{taxon.author_citation}</a>)
  end
end
