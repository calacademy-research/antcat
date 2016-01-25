Citrus.load "#{__dir__}/citation_grammar"

module Parsers::CitationParser

  def self.parse string
    return unless string.present?

    match = Parsers::CitationGrammar.parse(string, :consume => false)
    return unless match
    string.gsub! /#{Regexp.escape match}/, ''
    true
  end

end
