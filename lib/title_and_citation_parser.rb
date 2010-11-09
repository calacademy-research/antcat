require 'strscan'

module TitleAndCitationParser

  def self.parse string
    parse_bracketed_title_and_citation(string) ||
    parse_unbracketed_title_and_citation(string)
  end

  private

  def self.parse_bracketed_title_and_citation string
    return unless match = string.match(/(^\[.+?\])\.?\s/)
    title = string[0, match.end(1)]
    citation = CitationParser.parse string[match.end(0)..-1]
    {:title => title, :citation => citation}
  end

  def self.parse_unbracketed_title_and_citation string
    citation = first_possible_citation_start = first_possible_title_end = nil
    @scanner = StringScanner.new string
    while scan_to_sentence_end
      title_end = @scanner.pos
      first_possible_title_end ||= title_end
      @scanner.scan /\s*/
      next unless sentence_start? @scanner.rest
      first_possible_citation_start ||= @scanner.pos
      break if citation = CitationParser.parse(@scanner.rest, true)
    end

    unless citation
      title_end = first_possible_title_end
      citation = CitationParser.parse(string[first_possible_citation_start..-1], false)
    end
    {:title => string[0, title_end - 2], :citation => citation}
  end

  def self.scan_to_sentence_end
    @scanner.scan_until /\. /
  end

  def self.sentence_start? string
    string !~ /^[a-z]/
  end

  def self.remove_period_from text
    text[-1, 1] == '.' ? text[0..-2] : text 
  end

end
