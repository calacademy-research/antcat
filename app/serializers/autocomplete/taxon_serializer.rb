# frozen_string_literal: true

module Autocomplete
  class TaxonSerializer
    attr_private_initialize :taxon

    def as_json include_protonym: false
      {
        id: taxon.id,
        plaintext_name: taxon.name_cache,
        name_with_fossil: taxon.name_with_fossil,
        author_citation: taxon.author_citation,
        css_classes: CatalogFormatter.taxon_disco_mode_css(taxon),
        url: "/catalog/#{taxon.id}"
      }.tap do |hsh|
        hsh[:protonym] = Autocomplete::ProtonymSerializer.new(taxon.protonym).as_json if include_protonym
      end
    end

    def to_json options = {}
      as_json(**options).to_json
    end
  end
end
