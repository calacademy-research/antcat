class ReferenceParser

  def self.parse string
    string = string.dup
    parts = {}

    parts.merge_unless_nil! parse_authors string
    parts.merge_unless_nil! parse_year string
    parts.merge_unless_nil! parse_title_and_citation string

  end

  def self.parse_authors string
    authors_data = AuthorParser.parse(string)
    {:authors => authors_data[:names], :authors_role => authors_data[:role]}
  end

  def self.parse_year string
    match = string.strip.match /^(\d+)\s*\.\s*/
    return unless match.present?

    year = match[1]
    string[0..(match.end(0) - 1)] = ''
    {:year => year}
  end

  def self.parse_title_and_citation string
    result = TitleAndCitationParser.parse string
    {:title => result[:title]}.merge result[:citation]
  end

end

class Hash
  def merge_unless_nil! other_hash
    merge! other_hash unless other_hash.nil?
    self
  end
end

