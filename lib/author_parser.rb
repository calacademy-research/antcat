module AuthorParser

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
