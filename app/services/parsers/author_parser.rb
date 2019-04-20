Citrus.load "#{__dir__}/author_grammar", force: true unless defined? Parsers::AuthorGrammar

module Parsers::AuthorParser
  def self.parse string
    return [] if string.blank?
    string = string.dup

    match = Parsers::AuthorGrammar.parse(string, consume: false)
    result = match.value
    string.gsub! /#{Regexp.escape match}/, ''

    result[:names]
  rescue Citrus::ParseError
    []
  end

  def self.get_name_parts string
    parts = {}
    return parts if string.blank?
    matches = string.match /(.*?), (.*)/
    if matches
      parts[:last] = matches[1]
      parts[:first_and_initials] = matches[2]
    else
      parts[:last] = string
    end
    parts
  end
end
