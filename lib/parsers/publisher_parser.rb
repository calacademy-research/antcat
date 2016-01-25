Citrus.load "#{__dir__}/publisher_grammar"

module Parsers::PublisherParser
  def self.parse string
    Parsers::PublisherGrammar.parse(string.strip).value rescue nil
  end
end
