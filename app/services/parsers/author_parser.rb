Citrus.load "#{__dir__}/author_grammar", force: true unless defined? Parsers::AuthorGrammar

module Parsers
  class AuthorParser
    def self.parse string
      return [] if string.blank?
      string = string.dup

      match = Parsers::AuthorGrammar.parse(string, consume: false)
      result = match.value
      string.gsub! /#{Regexp.escape match}/, ''

      result[:names]
    rescue Citrus::ParseError
      []
    end
  end
end
