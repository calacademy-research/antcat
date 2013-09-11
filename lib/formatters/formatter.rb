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
    string = string.dup
    string.gsub!('<i>', '')
    string.gsub!('</i>', '')
    string.html_safe
  end

  def embolden string
    content_tag :b, string
  end

  def format_time_ago time
    return unless time
    content_tag :span, "#{time_ago_in_words time} ago", title: time
  end

  def format_doer_name user
    return "Someone" unless user
    content_tag(:a, user.name, href: %{mailto:"#{user.email}"}).html_safe
  end

  def format_name_linking_to_email name, email
    content_tag(:a, name, href: %{mailto:"#{email}"}).html_safe
  end

  def hash_to_params_string hash
    hash.keys.sort.inject(''.html_safe) do |string, key|
      key_and_value = %{#{key}="#{h hash[key]}"}
      string << '&'.html_safe if string.length != 0
      string << key_and_value.html_safe
      string
    end
  end

end
