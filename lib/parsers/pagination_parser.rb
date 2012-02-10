# coding: UTF-8
module Parsers::PaginationParser
  def self.parse string
    return unless string.present?
    pagination = Parsers::PaginationGrammar.parse string.strip, :consume => false
    return unless string =~ /#{Regexp.escape pagination}$/
    string.gsub! /#{Regexp.escape pagination}/, ''
    pagination
  end
end
