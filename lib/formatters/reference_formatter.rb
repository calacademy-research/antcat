# coding: UTF-8
class Formatters::ReferenceFormatter
  include ERB::Util
  extend ERB::Util

  def self.format reference, format = :html
    case reference
    when ArticleReference then Formatters::ArticleReferenceFormatter
    when BookReference then Formatters::BookReferenceFormatter
    when NestedReference then Formatters::NestedReferenceFormatter
    when UnknownReference then Formatters::UnknownReferenceFormatter
    else raise "Don't know what kind of reference this is: #{reference.inspect}"
    end.new(reference, format).format
  end

  def initialize reference, format
    @reference = reference
    @format = format
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
    h prefix + date + suffix
  end
end

class Formatters::ArticleReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.italicize self.class.add_period_if_necessary "#{h @reference.journal.name} #{h @reference.series_volume_issue}:#{h @reference.pagination}".html_safe
  end
end

class Formatters::BookReferenceFormatter < Formatters:: ReferenceFormatter
  def format_citation
    self.class.italicize self.class.add_period_if_necessary "#{h @reference.publisher}, #{h @reference.pagination}".html_safe
  end
end

class Formatters::UnknownReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.italicize self.class.add_period_if_necessary h @reference.citation
  end
end

class Formatters::NestedReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.italicize "#{h @reference.pages_in} #{Formatters::ReferenceFormatter.format(@reference.nested_reference)}".html_safe
  end
end
