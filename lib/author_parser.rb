require 'strscan'
require 'authors'

module AuthorParser

  def self.get_author_names string
    return [] unless string.present?
    parse = AuthorsParser.new.parse(string)
    authors = parse.authors.map {|e| e.dup}
    string[parse.interval] = ''
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
