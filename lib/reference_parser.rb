class ReferenceParser

  def parse_authors string
    return if string.blank?
    string.split /; ?/
  end

  def parse_citation citation
    return unless citation.present?
    parse_cd_rom_citation(citation) ||
    parse_nested_citation(citation) ||
    parse_book_citation(citation) ||
    parse_article_citation(citation) ||
    parse_unknown_citation(citation)
  end

  def parse_cd_rom_citation citation
    return unless citation =~ /CD-ROM/
    {:other => remove_period_from(citation)}
  end

  def parse_nested_citation citation
    return unless citation =~ /\bin: /i || citation =~ /^Pp\. \d+-\d+ in\b/
    {:other => remove_period_from(citation)}
  end

  def parse_article_citation citation
    parts = citation.match(/(.+?)(\S+)$/) or return
    journal_title = parts[1].strip

    parts = parts[2].match(/(.+?):(.+)$/) or return
    series_volume_issue = parts[1]
    pagination = remove_period_from parts[2]

    {:article => {:journal => journal_title, :series_volume_issue => series_volume_issue, :pagination => pagination}}
  end

  def parse_book_citation citation
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

  def parse_unknown_citation citation
    {:other => remove_period_from(citation)}
  end

  #def parse_cd_rom_citation data
    #return unless result = ReferenceParser.new.parse_cd_rom_citation(citation)
    #data.merge! :other => result
  #end

  #def parse_nested_citation data
    #return unless result = ReferenceParser.new.parse_nested_citation(citation)
    #data.merge! :other => result
  #end

  #def parse_book_citation data
    #return unless result = ReferenceParser.new.parse_book_citation(citation)
    #data.merge! :book => result
  #end

  #def parse_article_citation data
    #return unless result = ReferenceParser.new.parse_article_citation(citation)
    #data.merge! :article => result
  #end

  #def parse_unknown_citation data
    #data.merge! :other => ReferenceParser.new.parse_unknown_citation(citation)
  #end

  def pagination? string
    return true if contains_a_number_without_many_letters? string
    return false if contains_polish_conjunction? string
    return true if string =~ /\b[ivxlc]{1,3}\b/
    false
  end

  def contains_a_number_without_many_letters? string
    return false unless string =~ /\d/
    number_count = string.gsub(/\D/, '').length
    letter_count = string.gsub(/\W/, '').length
    return true if number_count > 4
    return false if letter_count - number_count > 12
    true
  end

  def contains_polish_conjunction? string
    string =~ /\w+ i \w+/ 
  end

  def remove_period_from text
    return if text.blank?
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

end
