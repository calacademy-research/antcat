module NestedCitationParser

  def self.parse string
    begin
      pages_in = PagesInGrammar.parse string
    rescue Citrus::ParseError
      pages_in = nil
    end
    return unless pages_in

    rest = string[pages_in.length..-1]
    inner = ReferenceParser.parse rest

    {:nested => inner.merge(:pages_in => pages_in.strip)}
  end

end
