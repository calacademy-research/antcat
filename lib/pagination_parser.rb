module PaginationParser
  Citrus.load 'lib/grammars/pagination' unless defined? PaginationGrammar

  def self.parse string
    return '' unless string.present?
    match = PaginationGrammar.parse(string)
    string.gsub! /#{Regexp.escape match}/, ''
    match
  end

end
