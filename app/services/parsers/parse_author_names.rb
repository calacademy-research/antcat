Citrus.load "#{__dir__}/author_grammar", force: true unless defined? Parsers::AuthorGrammar

module Parsers
  class ParseAuthorNames
    include Service

    def initialize string
      @string = string&.dup
    end

    def call
      return [] if string.blank?

      match = Parsers::AuthorGrammar.parse(string, consume: false)
      result = match.value
      string.gsub! /#{Regexp.escape match}/, ''

      result[:names]
    rescue Citrus::ParseError
      []
    end

    private

      attr_reader :string
  end
end
