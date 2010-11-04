class ReferenceParser

  def self.parse string
    string = string.dup
    parts = {}

    parts.merge_unless_nil! parse_authors string
    parts.merge_unless_nil! parse_year string
    parts.merge_unless_nil! parse_title string
    parts.merge_unless_nil! parse_citation string

    parts
  end

  def self.parse_authors string
    {:authors => AuthorParser.get_author_names(string)}
  end

  def self.parse_year string
    match = string.strip.match /^(\d+)\s*\.\s*/
    return unless match.present?

    year = match[1]
    string[0..(match.end(0) - 1)] = ''
    {:year => year}
  end

  def self.parse_title string
    # if the string contains the special journal name, the title is  everything up to it
    match = string.match(/(.*)(\.\s*)Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien/) ||
            string.match(/(.+?)(\.\s*)/)
    title = match[1]
    string.gsub! /#{Regexp.escape(match[1] + match[2])}/, ''
    {:title => title.strip}
  end

  def self.parse_citation string
    parse_cd_rom_citation(string) ||
    NestedCitationParser.parse(string) ||
    BookCitationParser.parse(string) ||
    ArticleCitationParser.parse(string) ||
    parse_unknown_citation(string)
  end

  def self.parse_cd_rom_citation citation
    return unless citation =~ /CD-ROM/
    {:other => remove_period_from(citation)}
  end

  def self.parse_unknown_citation citation
    {:other => remove_period_from(citation)}
  end

  def self.remove_period_from text
    return if text.blank?
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

end

class Hash
  def merge_unless_nil! other_hash
    merge! other_hash unless other_hash.nil?
    self
  end
end

