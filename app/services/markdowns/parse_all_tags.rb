# frozen_string_literal: true

module Markdowns
  class ParseAllTags
    include ActionView::Helpers::SanitizeHelper
    include Service

    def initialize content, sanitize_content: true
      @content = sanitize_content ? sanitize(content).to_str : content
    end

    def call
      parsed = Markdowns::ParseAntcatTags[content, sanitize_content: false]
      parsed = Markdowns::ParseCatalogTags[parsed, sanitize_content: false]

      parsed
    end

    private

      attr_reader :content
  end
end
