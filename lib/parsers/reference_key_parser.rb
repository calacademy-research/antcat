Citrus.load "#{__dir__}/reference_key_grammar"

module Parsers::ReferenceKeyParser

  def self.parse string
    Parsers::ReferenceKeyGrammar.parse(string).value
  end

end
