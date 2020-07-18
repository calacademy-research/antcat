# frozen_string_literal: true

module AntwebFormatter
  ANTCAT_BASE_URL = "https://www.antcat.org/"
  CATALOG_BASE_URL = "#{ANTCAT_BASE_URL}catalog/"
  PROTONYMS_BASE_URL = "#{ANTCAT_BASE_URL}protonyms/"

  module_function

  def detax taxt
    AntwebFormatter::Detax[taxt]
  end

  def link_to_taxon taxon
    %(<a href="#{CATALOG_BASE_URL}#{taxon.id}">#{taxon.name_with_fossil}</a>).html_safe
  end

  def link_to_taxon_with_label taxon, label
    %(<a href="#{CATALOG_BASE_URL}#{taxon.id}">#{label}</a>).html_safe
  end

  def link_to_taxon_with_author_citation taxon
    link_to_taxon(taxon) << ' ' << taxon.author_citation.html_safe
  end

  def link_to_protonym protonym
    %(<a href="#{PROTONYMS_BASE_URL}#{protonym.id}">#{protonym.decorate.name_with_fossil}</a>)
  end

  def link_to_protonym_with_author_citation protonym
    link_to_protonym(protonym).html_safe << ' ' << protonym.author_citation.html_safe
  end

  def link_to_reference reference
    AntwebFormatter::ReferenceLink[reference]
  end
end
