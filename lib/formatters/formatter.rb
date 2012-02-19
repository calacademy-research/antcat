# coding: UTF-8
module Formatters::Formatter
 extend ActionView::Helpers::NumberHelper

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
    items = items.flatten.uniq.map{|item| %{<span class="#{css_class}">#{item}</span>}}.sort
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
  module_function :add_period_if_necessary

end

