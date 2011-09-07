# coding: UTF-8
module AuthorParser

  def self.parse string
    return {:names => []} unless string.present?
    Citrus.require Rails.root.to_s + '/lib/grammar/author_grammar'
    match = AuthorGrammar.parse(string, :consume => false)
    result = match.value

    string.gsub! /#{Regexp.escape match}/, ''

    {:names => result[:names], :suffix => result[:suffix]}
  end

  def self.get_name_parts string
    parts = {}
    return parts unless string.present?
    matches = string.match /(.*?), (.*)/u
    unless matches
      parts[:last] = string
    else
      parts[:last] = matches[1]
      parts[:first_and_initials] = matches[2]
    end
    parts
  end

end
