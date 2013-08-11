# coding: UTF-8
module Formatters::Formatter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::DateHelper
  include ERB::Util

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

  def format_time_ago time
    content_tag :span, "#{time_ago_in_words time} ago", title: time
  end

  def format_doer_name user_id, what_they_did
    "#{user_id ? User.find(user_id).name : 'Someone'} #{what_they_did}"
  end

end
