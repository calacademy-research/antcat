require 'strscan'

module TitleParser

  def self.parse string
    title = find_title_before_citation(string)
    return title if title

    colon_index = string.index ':'
    string_before_colon = string[0, colon_index - 1]

    match = string.match /(^.*?)\.\s*/
    string[0, match[0].length] = ''
    match[1]
  end

  private
  def self.find_title_before_citation string
    scanner = StringScanner.new string
    while scanner.scan_until /\./
      period_pos = scanner.pos
      scanner.scan /\s*/
      if beginning_of_citation? scanner.rest
        title = string[0, period_pos - 1]
        string.replace scanner.rest
        return title
      end
    end
    nil
  end

  def self.beginning_of_citation? string
    pages_in?(string) || journal_title?(string)
  end

  def self.pages_in? string
    PagesInGrammar.parse string rescue nil
  end

  def self.journal_title? string
    string =~ /^Journal/
  end
end
