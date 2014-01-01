# coding: UTF-8
module Parsers::ReferenceKeyParser

  def self.parse string
    # explicit loading seems to help Citrus's problem with reloading its grammars
    # when Rails's class caching is off
    Citrus.load Rails.root.to_s + '/lib/parsers/common_grammar', force: true unless defined? Parsers::CommonGrammar
    Citrus.load Rails.root.to_s + '/lib/parsers/reference_key_grammar', force: true unless defined? Parsers::ReferenceKeyGrammar

    result = Parsers::ReferenceKeyGrammar.parse(string).value
    result
  end

end
