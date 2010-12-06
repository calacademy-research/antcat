module PaginationParser
  def self.parse string
    return unless string.present?
    pagination = PaginationGrammar.parse string.strip
    return unless string =~ /#{Regexp.escape pagination}$/
    string.gsub! /#{Regexp.escape pagination}/, ''
    pagination
  end
end
