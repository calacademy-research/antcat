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
    match = string.strip.match /(\d+)\s*\.\s*/
    return unless match.present?

    year = match[1]
    string[0..(match.end(0) - 1)] = ''
    {:year => year}
  end

  def self.parse_title string
    match = string.match /(.+?)\.\s*/
    title = match[1].strip
    string.gsub! /#{Regexp.escape match.to_s}/, ''
    {:title => title}
  end

  def self.parse_citation string
    parse_cd_rom_citation(string) ||
    NestedParser.parse(string) ||
    BookParser.parse(string) ||
    parse_article_citation(string) ||
    parse_unknown_citation(string)
  rescue
    puts string
    raise
  end

  def self.parse_article_citation string
    return unless string.present?
    parts = string.match(/(.+?)(\S+)$/) or return
    journal_title = parts[1].strip

    parts = parts[2].match /(.+?):(.+)$/
    return unless parts
    series_volume_issue = parts[1]
    pages = remove_period_from parts[2]

    {:article => {:journal => journal_title, :series_volume_issue => series_volume_issue, :pagination => pages}}
  end

  def self.parse_cd_rom_citation citation
    return unless citation =~ /CD-ROM/
    {:other => remove_period_from(citation)}
  end

  def self.parse_unknown_citation citation
    return unless citation.present?
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

