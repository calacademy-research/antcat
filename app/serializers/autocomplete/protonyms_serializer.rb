# frozen_string_literal: true

module Autocomplete
  class ProtonymsSerializer
    include Service

    attr_private_initialize :protonyms

    def call
      protonyms.map do |protonym|
        {
          id: protonym.id,
          plaintext_name: protonym.name.name,
          name_with_fossil: protonym.decorate.name_with_fossil,
          author_citation: protonym.author_citation,
          url: "/protonyms/#{protonym.id}"
        }
      end
    end
  end
end
