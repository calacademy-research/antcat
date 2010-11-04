require 'strscan'

module TitleParser

  def self.parse string
    title = find_title_before_citation(string)
    return title if title

    colon_index = string.index ':'

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
    starts_with_common_first_word_of_journal_name?(string) ||
    known_journal_name?(string)
  end

  def self.starts_with_common_first_word_of_journal_name? string
    string =~ /^(Abhandlungen|Acta|Actes|Anales|Annalen|Annales|Annali|Annals|Archives|Archivos|Arquivos|Boletim|Boletin|Bollettino|Bulletin|Izvestiya|Journal|Memoires|Memoirs|Memorias|Memorie|Mitteilungen|Occasional Papers)/
  end

  def self.known_journal_name? string
    return unless journal_title = JournalParser.parse(string.dup)
    Journal.find_by_title journal_title
  end

end
