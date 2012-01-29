# coding: UTF-8
module Formatter
  extend ActionView::Helpers::NumberHelper

  def pluralize_with_delimiters count, word, plural = nil
    if count != 1
      word = plural ? plural : word.pluralize
    end
    "#{number_with_delimiter(count)} #{word}"
  end

end
