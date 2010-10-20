class ReferenceParser

  def parse_nested_citation citation
    return unless citation =~ /\bin: /i || citation =~ /^Pp\. \d+-\d+ in\b/
    remove_period_from citation
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

    {:publisher => {:name => match[2], :place => match[1]}, :pagination => pagination}
  rescue => e
    puts citation
    raise
  end

  def pagination? string
    return true if string =~ /\d/
    return false if contains_polish_conjunction? string
    return true if string =~ /\b[ivxlc]{1,3}\b/
    false
  end

  def contains_polish_conjunction? string
    string =~ /\w+ i \w+/ 
  end

  def remove_period_from text
    return if text.blank?
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

end
