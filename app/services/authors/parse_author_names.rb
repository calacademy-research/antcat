# frozen_string_literal: true

Citrus.load "#{__dir__}/author_grammar", force: true unless defined? Authors::AuthorGrammar

module Authors
  class ParseAuthorNames
    include Service

    def initialize string
      @string = string.dup
    end

    def call
      return [] if string.blank?

      parsed.value[:names]
    rescue Citrus::ParseError
      []
    end

    private

      attr_reader :string

      def parsed
        Authors::AuthorGrammar.parse(string, consume: false)
      end
  end
end
