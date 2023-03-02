# frozen_string_literal: true

module AntwebTestLinksHelpers
  def antweb_taxon_link taxon
    AntwebFormatter.link_to_taxon(taxon)
  end

  def antweb_taxon_link_with_label taxon, label
    AntwebFormatter.link_to_taxon_with_label(taxon, label)
  end

  def antweb_protonym_link protonym
    AntwebFormatter.link_to_protonym(protonym)
  end

  def antweb_reference_link reference
    AntwebFormatter.link_to_reference(reference)
  end
end
