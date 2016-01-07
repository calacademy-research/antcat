module Parsers::PublisherParser
  def self.parse string
    # explicit loading seems to help Citrus's problem with reloading its grammars
    # when Rails's class caching is off
    Citrus.load Rails.root.to_s + '/lib/parsers/common_grammar', force: true unless defined? Parsers::CommonGrammar
    Citrus.load Rails.root.to_s + '/lib/parsers/publisher_grammar', force: true unless defined? Parsers::PublisherGrammar
    Parsers::PublisherGrammar.parse(string.strip).value rescue nil
  end
end
