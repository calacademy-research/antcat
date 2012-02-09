# coding: UTF-8
class ReferenceFormatter
  include ERB::Util
  extend ERB::Util

  ###########################
  def self.format reference
    make_formatter(reference).format
  end
  def self.format_inline_citation reference, user
    make_formatter(reference).format_inline_citation user
  end

  def format
    string = format_author_names
    string << ' ' unless string.empty?
    string << format_year << '. '
    string << format_title << ' '
    string << format_citation
    string << " [#{format_date(@reference.date)}]" if @reference.date?
    string
  end

  def format_year
    h @reference.citation_year
  end

  def format_author_names
    h @reference.author_names_string
  end

  def format_title
    self.class.italicize self.class.add_period_if_necessary h @reference.title
  end

  def self.italicize string
    return unless string
    raise "Can't italicize an unsafe string" unless string.html_safe?
    string = string.gsub /\*(.*?)\*/, '<span class=genus_or_species>\1</span>'
    string = string.gsub /\|(.*?)\|/, '<span class=genus_or_species>\1</span>'
    string.html_safe
  end

  def self.add_period_if_necessary string
    return unless string
    return string if string.empty?
    return string + '.' unless string[-1..-1] =~ /[.!?]/
    string
  end

  def self.format_timestamp timestamp
    timestamp.strftime '%Y-%m-%d'
  end

  def self.h_italic string
    string = string.gsub /<i>/, 'xxxx'
    string = string.gsub /<\/i>/, 'yyyy'
    string = h string
    string = string.gsub /xxxx/, '<i>'
    string = string.gsub /yyyy/, '</i>'
    string.html_safe
  end

  ###########################
  def initialize reference
    @reference = reference
  end

  def format
    s = ''
    s << "#{h_italic @reference.author_names_string}"
    s << ' ' unless s.empty?
    s << "#{h @reference.citation_year}. "
    s << "#{self.class.italicize(self.class.add_period_if_necessary(h @reference.title))} "
    s << self.class.italicize(format_citation)
    s << " [#{format_date(@reference.date)}]" if @reference.date?
    s.html_safe
  end

  def h_italic(string) self.class.h_italic string end

  def format_inline_citation user
    @reference.key.to_link user
  end

  private
  def format_date input
    input = h input.dup

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
    h prefix + date + suffix
  end

  def self.make_formatter reference
    raise "Don't know what kind of reference this is: #{reference.inspect}" unless
      ['Article', 'Book', 'Nested', 'Unknown', 'Missing'].map {|e| e + 'Reference'}.include? reference.class.name
    (reference.class.name + 'Formatter').constantize.new reference
  end

end

class ArticleReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.italicize self.class.add_period_if_necessary "#{h @reference.journal.name} #{h @reference.series_volume_issue}:#{h @reference.pagination}".html_safe
  end

end

class BookReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.italicize self.class.add_period_if_necessary "#{h @reference.publisher}, #{h @reference.pagination}".html_safe
  end
end

class UnknownReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.italicize self.class.add_period_if_necessary h @reference.citation
  end
end

class NestedReferenceFormatter < ReferenceFormatter
  def format_citation
    self.class.italicize "#{h @reference.pages_in} #{ReferenceFormatter.format(@reference.nested_reference)}".html_safe
  end
end

class MissingReferenceFormatter < ReferenceFormatter
  def format_inline_citation _ = nil
    @reference.citation
  end
end
