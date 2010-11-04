module BookCitationParser
  def self.parse string

    return unless string.present?

    string = string.dup
    pagination = parse_pagination string
    return unless pagination
    match = PublisherGrammar.parse string
    string.gsub! /#{Regexp.escape match}/, ''
    book = match.value
    book[:pagination] = pagination
    {:book => book}
  end

  def self.parse_pagination string
    pagination = nil
    start_of_comma_section = string.size
    loop do
      break unless start_of_comma_section = string.rindex(',', start_of_comma_section - 1)
      begin
        input = string.dup
        pagination = PaginationParser.parse input[(start_of_comma_section + 1)..-1].strip
      rescue Citrus::ParseError
        break
      end
    end
    string.gsub!(/,\s*#{Regexp.escape pagination}/, '') if pagination
    pagination
  end
end
