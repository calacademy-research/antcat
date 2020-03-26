# frozen_string_literal: true

Citrus.load "#{__dir__}/author_grammar", force: true unless defined? Parsers::AuthorGrammar

module Parsers
  class ParseAuthorNames
    include Service

    def initialize string
      @string = string&.dup
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
        Parsers::AuthorGrammar.parse(string, consume: false)
      end
  end
end
