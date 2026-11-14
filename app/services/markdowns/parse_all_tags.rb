# frozen_string_literal: true

# Expands every tag in Markdown content: the AntCat tags (users, wiki pages, database scripts, GitHub issues) and
# the catalog tags.
module Markdowns
  class ParseAllTags
    include Service

    def initialize content
      @content = content
    end

    def call
      parsed = Markdowns::ParseAntCatTags[content]
      parsed = Markdowns::ParseCatalogTags[parsed]

      parsed
    end

    private

      attr_reader :content
  end
end
