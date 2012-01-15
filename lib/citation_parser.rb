# coding: UTF-8
module CitationParser

  def self.parse string
    return unless string.present?

    match = CitationGrammar.parse(string, consume: false)
    return unless match
    string.gsub! /#{Regexp.escape match}/, ''
    true
  end

end
