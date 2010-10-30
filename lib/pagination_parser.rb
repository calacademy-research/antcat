module PaginationParser

  def self.parse string
    return '' unless string.present?
    Citrus.load 'lib/grammars/pagination' unless defined? PaginationGrammar
    match = PaginationGrammar.parse(string)
    string.gsub! /#{Regexp.escape match}/, ''
    match
  end

end
