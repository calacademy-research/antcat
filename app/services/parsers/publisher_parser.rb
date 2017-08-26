Citrus.load "#{__dir__}/common_grammar", force: true unless defined? Parsers::CommonGrammar
Citrus.load "#{__dir__}/publisher_grammar", force: true unless defined? Parsers::PublisherGrammar

module Parsers::PublisherParser
  def self.parse string
    Parsers::PublisherGrammar.parse(string.strip).value rescue nil
  end
end
