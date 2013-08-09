# coding: UTF-8
module Formatters::Formatter
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::DateHelper
  include ERB::Util
  extend ERB::Util

  module_function

  def pluralize_with_delimiters count, word, plural = nil
    if count != 1
      word = plural ? plural : word.pluralize
    end
    "#{number_with_delimiter(count)} #{word}"
  end

  def count_and_noun collection, noun
    quantity = collection.present? ? collection.count.to_s : 'no'
    noun << 's' unless collection.count == 1
    "#{quantity} #{noun}"
  end

  def conjuncted_list items, css_class
    items = items.flatten.uniq.map{|item| %{<span class="#{css_class}">}.html_safe + item + %{</span>}.html_safe}.sort
    case
    when items.count == 0
      ''
    when items.count == 1
      items.first
    when items.count == 2
      items.first + ' and ' + items.second
    else
      items[0..-2].join(', ') + ' and ' + items.last
    end.html_safe
  end

  def add_period_if_necessary string
    return unless string
    return string if string.empty?
    return string + '.' unless string[-1..-1] =~ /[.!?]/
    string
  end

  def italicize string
    content_tag :i, string
  end

  def unitalicize string
    raise "Can't unitalicize an unsafe string" unless string.html_safe?
    string.gsub(%r{<i>(.*)</i>}, '\1').html_safe
  end

  def embolden string
    content_tag :b, string
  end

  def link contents, href, attributes = {}
    attributes = attributes.dup
    attributes[:target] = '_blank' unless attributes.include? :target
    attributes.delete(:target) if attributes[:target].nil?
    attributes[:href] = href
    attributes_string = attributes.keys.sort.inject(''.html_safe) do |string, key|
      string << "#{key}=\"#{h attributes[key]}\" ".html_safe
    end.strip.html_safe
    '<a '.html_safe + attributes_string + '>'.html_safe + contents + '</a>'.html_safe
  end

  def link_to_external_site label, url
    link label, url, class: 'link_to_external_site'
  end

  def format_time_ago time
    content_tag :span, "#{time_ago_in_words time} ago", title: time
  end

  def format_approver_name user
    "#{user ? user.name : 'Someone'} approved this change"
  end

end
