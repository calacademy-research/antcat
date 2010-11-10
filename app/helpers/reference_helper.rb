module ReferenceHelper
  def format_reference reference
    ReferenceHelperBase.format self, reference
  end

  def italicize s
    return unless s
    s = s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=taxon>\1</span>'
  end
end

class ReferenceHelperBase
  include ERB::Util

  def self.format helper, reference
    case reference
    when ArticleReference then ArticleHelper
    when BookReference then BookHelper
    when NestedReference then NestedHelper
    when UnknownReference then UnknownHelper
    else raise "Don't know what kind of reference this is: #{reference.inspect}"
    end.new(helper, reference).format
  end

  def initialize helper, reference
    @helper = helper
    @reference = reference
  end

  def format
    s = ''
    s << "#{h @reference.authors_string} "
    s << "#{h @reference.citation_year}. "
    s << "#{@helper.italicize(Reference.add_period_if_necessary(h @reference.title))} "
    s << format_citation
    s << " [#{format_date(@reference.date)}]" if @reference.date.present?
    s
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

class ArticleHelper < ReferenceHelperBase
  def format_citation
    Reference.add_period_if_necessary "#{@reference.journal.name} #{@reference.series_volume_issue}:#{@reference.pagination}"
  end
end

class BookHelper < ReferenceHelperBase
  def format_citation
    Reference.add_period_if_necessary "#{@reference.publisher}, #{@reference.pagination}"
  end
end

class UnknownHelper < ReferenceHelperBase
  def format_citation
    Reference.add_period_if_necessary @reference.citation
  end
end

class NestedHelper < ReferenceHelperBase
  def format_citation
    "#{@reference.pages_in}#{ReferenceHelperBase.format(@helper, @reference.nested_reference)}"
  end
end
