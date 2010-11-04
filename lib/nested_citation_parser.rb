module NestedCitationParser

  def self.parse string
    return unless string.present?

    matches = string.match(/^.*\d.*?\s*\bIn\b\s*:?\s*/i) || string.match(/In: /)
    return unless matches.present?

    rest = string[matches.end(0)..-1].strip

    inner = ReferenceParser.parse rest
    pages_in = matches[0].strip

    {:nested => inner.merge(:pages_in => pages_in.strip)}
  end

end
