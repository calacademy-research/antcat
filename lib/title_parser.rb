require 'strscan'

module TitleParser

  def self.parse string
    title = find_title_before_citation(string)
    return title if title

    match = string.match /(^.*?)\.\s*/
    string[0, match[0].length] = ''
    match[1]
  end

  private
  def self.find_title_before_citation string
    end_of_title = nil
    start_of_citation = nil
    @scanner = StringScanner.new string

    while scan_until_possible_end_of_title
      period_pos = @scanner.pos
      @scanner.scan /\s*/
      next unless can_be_start_of_citation? @scanner.rest

      end_of_title ||= (period_pos - 1)
      start_of_citation ||= @scanner.pos

      if start_of_citation? @scanner.rest
        end_of_title = period_pos - 1
        start_of_citation = @scanner.pos
        break
      end
    end
    if end_of_title
      title = string[0, end_of_title]
      string[0, start_of_citation] = ''
      return title
    end
    nil
  end

  def self.scan_until_possible_end_of_title
    @scanner.scan_until /(\.\] )|(\]\.)|(\.)/
  end

  def self.can_be_start_of_citation? string
    string !~ /^[a-z\,]/
  end

  def self.start_of_citation? string
    pages_in?(string) || journal_title?(string) || known_place_name?(string)
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

  def self.known_place_name? string
    return unless publisher = PublisherParser.parse(string.dup)
    Place.find_by_name publisher[:place]
  end

end
