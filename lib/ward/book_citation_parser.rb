module Ward::BookCitationParser

  def self.parse string, possibly_embedded
    return unless string.present?
    string = string.dup

    pagination = parse_pagination string
    return unless pagination

    match = PublisherGrammar.parse string
    return unless match.value[:publisher][:place].length > 2
    string.gsub! /#{Regexp.escape match}/, ''
    book = match.value
    return unless place?(book[:publisher][:place], possibly_embedded)

    book[:pagination] = pagination
    {:book => book}

  rescue Citrus::ParseError
    nil
  end

  def self.parse_pagination string
    pagination = nil
    start_of_comma_section = string.size
    loop do
      break unless start_of_comma_section = string.rindex(',', start_of_comma_section - 1)
      begin
        input = string.dup
        pagination = Ward::PaginationParser.parse input[(start_of_comma_section + 1)..-1].strip
      rescue Citrus::ParseError
        break
      end
    end
    string.gsub!(/,\s*#{Regexp.escape pagination}/, '') if pagination
    pagination
  end

  private
  def self.place? place, possibly_embedded
    !possibly_embedded || place.index('.') == nil || Place.find_by_name(place)
  end
end
