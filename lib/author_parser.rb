module AuthorParser
  Citrus.load 'lib/grammars/authors' unless defined? AuthorsGrammar

  def self.get_author_names string
    return [] unless string.present?
    match = AuthorsGrammar.parse(string)

    authors = match.value
    string.gsub! /#{Regexp.escape match}/, ''
    authors
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
