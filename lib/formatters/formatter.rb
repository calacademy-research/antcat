# coding: UTF-8
module Formatters::Formatter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::DateHelper
  include ERB::Util

  include ApplicationHelper #pluralize_with_delimiters

  def conjuncted_list items, css_class
    items = items.flatten.uniq.map do |item|
      %{<span class="#{css_class}">}.html_safe + item + %{</span>}.html_safe
    end.sort
    items.to_sentence(last_word_connector: " and ").html_safe
  end

  def add_period_if_necessary string
    return unless string.present?
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

  def hash_to_params_string hash
    hash.keys.sort.inject(''.html_safe) do |string, key|
      key_and_value = %{#{key}=#{h hash[key]}}
      string << '&'.html_safe unless string.empty?
      string << key_and_value.html_safe
    end
  end

end
