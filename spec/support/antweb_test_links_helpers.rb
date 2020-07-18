# frozen_string_literal: true

module AntwebTestLinksHelpers
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
