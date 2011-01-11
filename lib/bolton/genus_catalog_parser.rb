module Bolton::GenusCatalogParser

  def self.parse string
    string = string.gsub(/\n/, ' ').strip
    Bolton::GenusCatalogGrammar.parse(string).value
  rescue Citrus::ParseError => e
    p e if Rails.env.development?
    :unparseable
  end

end
