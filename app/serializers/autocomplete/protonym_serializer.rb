# frozen_string_literal: true

module Autocomplete
  class ProtonymSerializer
    attr_private_initialize :protonym

    def as_json _options = {}
      {
        id: protonym.id,
        plaintext_name: protonym.name.name,
        name_with_fossil: protonym.decorate.name_with_fossil,
        author_citation: protonym.author_citation,
        css_classes: 'protonym',
        url: "/protonyms/#{protonym.id}"
      }
    end

    def to_json options = {}
      as_json(options).to_json
    end
  end
end
