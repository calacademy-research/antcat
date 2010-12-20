class Bolton::ReferenceFormatter
  include ERB::Util

  def self.format reference, format = :html
    case reference.reference_type
    when 'ArticleReference' then Bolton::ArticleReferenceFormatter
    when 'BookReference' then Bolton::BookReferenceFormatter
    when 'NestedReference' then Bolton::NestedReferenceFormatter
    when 'UnknownReference' then Bolton::UnknownReferenceFormatter
    else raise "Don't know what kind of reference this is: #{reference.inspect}"
    end.new(reference, format).format
  end

  def initialize reference, format
    @reference = reference
    @format = format
  end

  def format
    s = ''
    s << "#{h @reference.authors}"
    s << ' ' unless s.empty?
    s << "#{h @reference.year}. "
    s << "#{self.class.add_period_if_necessary(h @reference.title)} "
    s << format_citation
    s << " [#{h @reference.note}]" if @reference.note.present?
    s << " (#{@reference.reference_type.gsub(/Reference/, '')})"
    s
  end

  def self.add_period_if_necessary string
    return unless string
    return string if string.empty?
    return string + '.' unless string[-1..-1] == '.'
    string
  end

end

class Bolton::ArticleReferenceFormatter < Bolton::ReferenceFormatter
  def format_citation
    self.class.add_period_if_necessary "#{h @reference.journal} #{h @reference.series_volume_issue}:#{h @reference.pagination}"
  end
end

class Bolton::BookReferenceFormatter < Bolton::ReferenceFormatter
  def format_citation
    self.class.add_period_if_necessary "#{h @reference.publisher}, #{h @reference.pagination}"
  end
end

class Bolton::UnknownReferenceFormatter < Bolton::ReferenceFormatter
  def format_citation
    ''
  end
end

class Bolton::NestedReferenceFormatter < Bolton::ReferenceFormatter
  def format_citation
    return ''
    "#{h @reference.pages_in} #{ReferenceFormatter.format(@reference.nested_reference)}"
  end
end
