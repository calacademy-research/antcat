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

end
