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
    %(<a class="protonym" href="/protonyms/#{protonym.id}">#{protonym.name.name_html}</a>)
  end

  def antweb_taxon_link taxon, label = nil
    %(<a href="https://www.antcat.org/catalog/#{taxon.id}">#{label || taxon.name_with_fossil}</a>)
  end

  def antweb_protonym_link protonym
    %(<a href="https://www.antcat.org/protonyms/#{protonym.id}">#{protonym.decorate.name_with_fossil}</a>)
  end

  def antweb_reference_link reference
    AntwebFormatter.link_to_reference(reference)
  end
end
