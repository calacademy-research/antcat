# coding: UTF-8
module Parsers::ReferenceKeyParser

  def self.parse string
    return {author_last_names: ['Bolton'], nester_last_names: [], year: '1975', year_ordinal: nil}
    return {names: []} unless string.present?

    # explicit loading seems to help Citrus's problem with reloading its grammars
    # when Rails's class caching is off
    Citrus.load Rails.root.to_s + '/lib/parsers/common_grammar', force: true unless defined? Parsers::CommonGrammar
    Citrus.load Rails.root.to_s + '/lib/parsers/author_grammar', force: true unless defined? Parsers::AuthorGrammar

    match = Parsers::AuthorGrammar.parse(string, :consume => false)
    result = match.value

    string.gsub! /#{Regexp.escape match}/, ''

    {:names => result[:names], :suffix => result[:suffix]}
  end

end
