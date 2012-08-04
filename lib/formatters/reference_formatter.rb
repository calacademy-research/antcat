# coding: UTF-8
class Formatters::ReferenceFormatter
  include ERB::Util
  extend ERB::Util
  include Formatters::Formatter

  def self.format reference
    make_formatter(reference).format
  end

  def self.format_inline_citation reference, user = nil, options = {}
    make_formatter(reference).format_inline_citation user, options
  end

  def self.italicize string
    return unless string
    raise "Can't italicize an unsafe string" unless string.html_safe?
    string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
    string = string.gsub /\|(.*?)\|/, '<i>\1</i>'
    string.html_safe
  end

  def self.format_timestamp timestamp
    timestamp.strftime '%Y-%m-%d'
  end

  ##################
  def initialize reference
    @reference = reference
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

  def format_author_names
    h @reference.author_names_string
  end

  def format_year
    h @reference.citation_year
  end

  def format_title
    self.class.italicize add_period_if_necessary h @reference.title
  end

  def format_inline_citation user, options = {}
    @reference.key.to_link user, options
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

  def self.make_formatter reference
    reference.to_class('Formatter', 'Formatters::').new reference
  end
end

class Formatters::ArticleReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.italicize add_period_if_necessary "#{h @reference.journal.name} #{h @reference.series_volume_issue}:#{h @reference.pagination}".html_safe
  end
end

class Formatters::BookReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.italicize add_period_if_necessary "#{h @reference.publisher}, #{h @reference.pagination}".html_safe
  end
end

class Formatters::UnknownReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.italicize add_period_if_necessary h @reference.citation
  end
end

class Formatters::NestedReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.italicize "#{h @reference.pages_in} #{Formatters::ReferenceFormatter.format(@reference.nested_reference)}".html_safe
  end
end

class Formatters::MissingReferenceFormatter < Formatters::ReferenceFormatter
  def format_inline_citation reference = nil, user = nil, options = nil
    @reference.citation
  end
end
