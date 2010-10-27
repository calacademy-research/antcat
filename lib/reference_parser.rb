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
    match = string.match /(.+?)\./
    title = match[1].strip
    string[0..(match.end(0) - 1)] = ''
    {:title => title}
  end

  def self.parse_citation string
    parse_cd_rom_citation(string) ||
    parse_nested_citation(string) ||
    parse_book_citation(string) ||
    parse_article_citation(string) ||
    parse_unknown_citation(string)
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

  def self.parse_nested_citation citation
    return unless citation =~ /\bin: /i || citation =~ /^Pp\. \d+-\d+ in\b/
    {:other => remove_period_from(citation)}
  end

  def self.parse_book_citation citation
    return unless citation =~ /.+: .+, .+$/
    comma_sections = citation.split ','
    pagination_sections = []
    last_pagination_section = 0
    comma_sections.reverse.each_with_index do |comma_section, i|
      if pagination? comma_section
        pagination_sections.insert 0, comma_section
        last_pagination_section = i
      else
        break
      end
    end
    pagination = pagination_sections.join(',').strip

    place_and_publisher = comma_sections[0..(-last_pagination_section - 2)].join(',').strip
    match = place_and_publisher.match /(.*?): (.*)/

    {:book => {:publisher => {:name => match[2], :place => match[1]}, :pagination => pagination}}
  rescue => e
    puts citation
    raise
  end

  def self.parse_unknown_citation citation
    return unless citation.present?
    {:other => remove_period_from(citation)}
  end

  def self.pagination? string
    return true if contains_a_number_without_many_letters? string
    return false if contains_polish_conjunction? string
    return true if string =~ /\b[ivxlc]{1,3}\b/
    false
  end

  def self.contains_a_number_without_many_letters? string
    return false unless string =~ /\d/
    number_count = string.gsub(/\D/, '').length
    letter_count = string.gsub(/\W/, '').length
    return true if number_count > 4
    return false if letter_count - number_count > 12
    true
  end

  def self.contains_polish_conjunction? string
    string =~ /\w+ i \w+/ 
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

