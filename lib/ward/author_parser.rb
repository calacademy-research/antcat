module Ward::AuthorParser
  def self.parse string
    return {:names => []} unless string.present?
    match = AuthorGrammar.parse(string)
    result = match.value

    if is_actually_the_title? result[:names].first
      result[:names] = []
      result[:suffix] = nil
    else
      string.gsub! /#{Regexp.escape match}/, ''
    end
    {:names => result[:names], :suffix => result[:suffix]}
  end

  def self.is_actually_the_title? name
    name !~ /,/ && !AuthorName.first(:conditions => ['name = ? AND verified = 1', name])
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
