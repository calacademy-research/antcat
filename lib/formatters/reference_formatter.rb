# coding: UTF-8
class Formatters::ReferenceFormatter
  include ERB::Util
  extend ERB::Util
  include Formatters::Formatter
  extend ActionView::Context
  extend Sprockets::Helpers::RailsHelper

  def self.format reference
    make_formatter(reference).format
  end

  def self.format! reference
    make_formatter(reference).format!
  end

  def self.make_formatter reference
    reference.to_class('Formatter', 'Formatters::').new reference
  end

  def self.format_inline_citation reference, user = nil, options = {}
    make_formatter(reference).format_inline_citation user, options
  end

  def self.format_inline_citation! reference, user = nil, options = {}
    make_formatter(reference).format_inline_citation! user, options
  end

  def self.format_inline_citation_without_links reference, user = nil, options = {}
    make_formatter(reference).format_inline_citation_without_links user, options
  end

  def self.format_authorship_html reference
    content = format_authorship reference
    title = format reference
    content_tag(:span, title: title) {content}
  end

  def self.format_authorship reference
    reference.key.to_s
  end

  def self.format_italics string
    return unless string
    raise "Can't call format_italics on an unsafe string" unless string.html_safe?
    string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
    string = string.gsub /\|(.*?)\|/, '<i>\1</i>'
    string.html_safe
  end

  def self.format_timestamp timestamp
    timestamp.strftime '%Y-%m-%d'
  end

  def self.format_review_state review_state
    return 'Being reviewed' if review_state == 'reviewing'
    return '' if review_state == 'none'
    review_state.present? ? review_state.capitalize : ''
  end

  def self.make_html_safe string
    string = string.dup
    quote_code = 'xdjvs4'
    begin_italics_code = '2rjsd4'
    end_italics_code = '1rjsd4'
    string.gsub! '<i>', begin_italics_code
    string.gsub! '</i>', end_italics_code
    string.gsub! '"', quote_code
    string = h string
    string.gsub! quote_code, '"'
    string.gsub! end_italics_code, '</i>'
    string.gsub! begin_italics_code, '<i>'
    string.html_safe
  end

  ##################
  def initialize reference
    @reference = reference
  end

  def format
    string = ReferenceFormatterCache.instance.get @reference, :formatted_cache
    return string.html_safe if string
    string = format!
    ReferenceFormatterCache.instance.set @reference, string, :formatted_cache
    string
  end

  def format!
    string = format_author_names.dup
    string << ' ' unless string.empty?
    string << format_year << '. '
    string << format_title << ' '
    string << format_citation
    string << " [#{format_date(@reference.date)}]" if @reference.date?
    string
  end

  def format_author_names
    self.class.make_html_safe @reference.author_names_string
  end

  def format_year
    self.class.make_html_safe @reference.citation_year if @reference.citation_year?
  end

  def format_title
    self.class.format_italics add_period_if_necessary self.class.make_html_safe @reference.title
  end

  def format_inline_citation user, options = {}
    using_cache = options == {expanded: true} && user.present?
    if using_cache
      string = ReferenceFormatterCache.instance.get @reference, :inline_citation_cache
      return string.html_safe if string
    end
    string = format_inline_citation! user, options
    if using_cache
      ReferenceFormatterCache.instance.set @reference, string, :inline_citation_cache
    end
    string
  end

  def format_inline_citation! user, options = {}
    @reference.key.to_link user, options
  end

  def format_inline_citation_without_links user, options = {}
    @reference.key.to_s
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
    self.class.format_italics add_period_if_necessary "#{h @reference.journal.name} #{h @reference.series_volume_issue}:#{h @reference.pagination}".html_safe
  end
end

class Formatters::BookReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.format_italics add_period_if_necessary "#{h @reference.publisher}, #{h @reference.pagination}".html_safe
  end
end

class Formatters::UnknownReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.format_italics add_period_if_necessary self.class.make_html_safe(@reference.citation)
  end
end

class Formatters::NestedReferenceFormatter < Formatters::ReferenceFormatter
  def format_citation
    self.class.format_italics "#{h @reference.pages_in} #{Formatters::ReferenceFormatter.format(@reference.nesting_reference)}".html_safe
  end
end

class Formatters::MissingReferenceFormatter < Formatters::ReferenceFormatter
  def format_inline_citation reference = nil, user = nil, options = nil
    self.class.make_html_safe @reference.citation
  end
  def format_citation
    self.class.make_html_safe @reference.citation
  end
end
