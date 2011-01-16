class ReferenceFormatter
  include ERB::Util

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
    s << "#{h @reference.author_names_string}"
    s << ' ' unless s.empty?
    s << "#{h @reference.citation_year}. "
    s << "#{self.class.italicize(self.class.add_period_if_necessary(h @reference.title))} "
    s << self.class.italicize(format_citation)
    s << " [#{h format_date(@reference.date)}]" if @reference.date.present?
    s
  end

  def self.italicize s
    return unless s
    s = s.gsub /\*(.*?)\*/, '<span class=genus_or_species>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=genus_or_species>\1</span>'
  end

  def self.add_period_if_necessary string
    return unless string
    return string if string.empty?
    return string + '.' unless string[-1..-1] == '.'
    string
  end

  def self.format_timestamp timestamp
    timestamp.strftime '%Y-%m-%d'
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
    self.class.add_period_if_necessary "#{h @reference.journal.name} #{h @reference.series_volume_issue}:#{h @reference.pagination}"
  end
end

class BookReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.add_period_if_necessary "#{h @reference.publisher}, #{h @reference.pagination}"
  end
end

class UnknownReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.add_period_if_necessary h @reference.citation
  end
end

class NestedReferenceFormatter < ReferenceFormatter
  def format_citation
    "#{h @reference.pages_in} #{ReferenceFormatter.format(@reference.nested_reference)}"
  end
end
