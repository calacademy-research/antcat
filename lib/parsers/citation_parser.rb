Citrus.load "#{__dir__}/common_grammar", force: true unless defined? Parsers::CommonGrammar
Citrus.load "#{__dir__}/author_grammar", force: true unless defined? Parsers::AuthorGrammar
Citrus.load "#{__dir__}/citation_grammar", force: true unless defined? Parsers::CitationGrammar

module Parsers::CitationParser
  def self.parse string
    return unless string.present?

    match = Parsers::CitationGrammar.parse(string, consume: false)
    return unless match
    string.gsub! /#{Regexp.escape match}/, ''
    true
  end
end
