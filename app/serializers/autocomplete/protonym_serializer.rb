# frozen_string_literal: true

module Autocomplete
  class ProtonymSerializer
    attr_private_initialize :protonym

    def as_json include_terminal_taxon: false
      {
        id: protonym.id,
        plaintext_name: protonym.name.name,
        name_with_fossil: protonym.decorate.name_with_fossil,
        author_citation: protonym.author_citation,
        css_classes: 'protonym',
        url: "/protonyms/#{protonym.id}"
      }.tap do |hsh|
        hsh[:terminal_taxon] = serialized_terminal_taxon if include_terminal_taxon
      end
    end

    def to_json options = {}
      as_json(**options).to_json
    end

    private

      def serialized_terminal_taxon
        return unless (terminal_taxon = protonym.terminal_taxon)
        Autocomplete::TaxonSerializer.new(terminal_taxon).as_json
      end
  end
end
