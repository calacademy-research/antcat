class ReferenceFormatter
  def self.format reference, format = :html
    case reference
    when ArticleReference then ArticleReferenceFormatter
    when BookReference then BookReferenceFormatter
    when NestedReference then NestedReferenceFormatter
    when UnknownReference then UnknownReferenceFormatter
    else raise "Don't know what kind of reference this is: #{reference.inspect}"
    end.new(reference, format).format
  end

  def initialize reference, format
    @reference = reference
    @format = format
  end

  def format
    s = ''
    s << "#{@reference.authors_string} "
    s << "#{@reference.citation_year}. "
    s << "#{self.class.italicize(self.class.add_period_if_necessary(@reference.title))} "
    s << format_citation
    s << " [#{format_date(@reference.date)}]" if @reference.date.present?
    s
  end

  def self.italicize s
    return unless s
    s = s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=taxon>\1</span>'
  end

  def self.add_period_if_necessary string
    return unless string
    return string if string.empty?
    return string + '.' unless string[-1..-1] == '.'
    string
  end

  private
  def format_date input
    date = input
    return date if input.length < 4

    match = input.match(/(.*?)(\d{4,8})(.*)/)
    prefix = match[1]
    input = match[2]
    suffix = match[3]

    date = input[0, 4]
    return prefix + date + suffix if input.length < 6
    date << '-' << input[4, 2]
    return prefix + date + suffix if input.length < 8
    date << '-' << input[6, 2]
    prefix + date + suffix
  end
end

class ArticleReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.add_period_if_necessary "#{@reference.journal.name} #{@reference.series_volume_issue}:#{@reference.pagination}"
  end
end

class BookReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.add_period_if_necessary "#{@reference.publisher}, #{@reference.pagination}"
  end
end

class UnknownReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.add_period_if_necessary @reference.citation
  end
end

class NestedReferenceFormatter < ReferenceFormatter
  def format_citation
    "#{@reference.pages_in} #{ReferenceFormatter.format(@reference.nested_reference)}"
  end
end
