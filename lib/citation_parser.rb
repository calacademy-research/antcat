class CitationParser
  def self.parse string, possibly_embedded = false
    NestedCitationParser.parse(string) ||
    ArticleCitationParser.parse(string, possibly_embedded) ||
    BookCitationParser.parse(string, possibly_embedded) ||
    !possibly_embedded && parse_unknown_citation(string)
  end

  def self.parse_unknown_citation citation
    {:unknown => remove_period_from(citation)}
  end

  def self.remove_period_from text
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

end

