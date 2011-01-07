module Bolton::GenusCatalogParser

  def self.parse string
    string = string.gsub(/\n/, ' ').strip
    Bolton::GenusCatalogGrammar.parse(string).value
  rescue Citrus::ParseError
    nil
  end

end
