# coding: UTF-8
module Parsers::AuthorParser

  def self.parse! string
    return {:names => []} unless string.present?

    # explicit loading seems to help Citrus's problem with reloading its grammars
    # when Rails's class caching is off
    Citrus.load Rails.root.to_s + '/lib/parsers/common_grammar', force: true unless defined? Parsers::CommonGrammar
    Citrus.load Rails.root.to_s + '/lib/parsers/author_grammar', force: true unless defined? Parsers::AuthorGrammar

    match = Parsers::AuthorGrammar.parse(string, :consume => false)
    result = match.value

    string.gsub! /#{Regexp.escape match}/, ''

    {:names => result[:names], :suffix => result[:suffix]}
  end

  def self.parse string
    string &&= string.dup
    parse! string
  end

  def self.get_name_parts string
    parts = {}
    return parts unless string.present?
    matches = string.match /(.*?), (.*)/
    unless matches
      parts[:last] = string
    else
      parts[:last] = matches[1]
      parts[:first_and_initials] = matches[2]
    end
    parts
  end

end
