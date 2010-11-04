module AuthorParser
  def self.get_author_names string
    return [] unless string.present?
    match = AuthorGrammar.parse(string)

    authors = match.value

    if is_actually_the_title? authors.first
      authors = []
    else
      string.gsub! /#{Regexp.escape match}/, ''
    end
    authors
  end

  def self.is_actually_the_title? name
    name !~ /,/ &&
         !['Anonymous',
           'International Commission on Zoological Nomenclature',
           'Österreichischen Gesellschaft für Ameisenkunde',
          ].include?(name)
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
