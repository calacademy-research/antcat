require 'strscan'

module TitleAndCitationParser

  def self.parse string
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
    {:title => remove_extra_characters_from_end_of(string[0, title_end]), :citation => citation}
  end

  def self.scan_to_sentence_end
    if @scanner.peek(1) == '['
      @scanner.scan_until /\]\.? /
    else
      @scanner.scan_until /\. /
    end
  end

  def self.sentence_start? string
    string !~ /^[a-z]/
  end

  def self.remove_extra_characters_from_end_of text
    text.gsub /\.? ?$/ , ''
  end

end
