class CitationParser
  def self.parse string, allow_other = true
    (allow_other && parse_cd_rom_citation(string)) ||
    NestedCitationParser.parse(string) ||
    ArticleCitationParser.parse(string) ||
    BookCitationParser.parse(string) ||
    (allow_other && parse_unknown_citation(string))
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

  #def self.journal_title? string
    #starts_with_common_first_word_of_journal_name?(string) ||
    #known_journal_name?(string)
  #end

  #def self.starts_with_common_first_word_of_journal_name? string
    #string =~ /^(Abhandlungen|Acta|Actes|Anales|Annalen|Annales|Annali|Annals|Archives|Archivos|Arquivos|Boletim|Boletin|Bollettino|Bulletin|Izvestiya|Journal|Memoires|Memoirs|Memorias|Memorie|Mitteilungen|Occasional Papers)/
  #end

  #def self.known_journal_name? string
    #return unless journal_title = JournalParser.parse(string.dup)
    #Journal.find_by_title journal_title
  #end

end

