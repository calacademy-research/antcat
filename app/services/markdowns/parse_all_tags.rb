# frozen_string_literal: true

module Markdowns
  class ParseAllTags
    include Service

    def initialize content
      @content = content
    end

    def call
      parsed = Markdowns::ParseAntcatTags[content]
      parsed = Markdowns::ParseCatalogTags[parsed]

      parsed
    end

    private

      attr_reader :content
  end
end
