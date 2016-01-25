module Parsers::ReferenceKeyParser

  def self.parse string
    Parsers::ReferenceKeyGrammar.parse(string).value
  end

end
