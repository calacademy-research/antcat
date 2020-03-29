# frozen_string_literal: true

module AntwebFormatter
  CATALOG_URL = "https://www.antcat.org/catalog/"

  module_function

  def link_to_taxon taxon, label: nil
    %(<a href="#{CATALOG_URL}#{taxon.id}">#{label || taxon.name_with_fossil}</a>).html_safe
  end

  def link_to_taxon_with_author_citation taxon
    link_to_taxon(taxon) << ' ' << taxon.author_citation.html_safe
  end
end
