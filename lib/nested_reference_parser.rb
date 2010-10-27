module NestedReferenceParser

  def self.parse string
    return unless string.present?
    string = string.dup

    matches = string.match /^Pp\. (\d+-\d+) in/
    return unless matches.present?

    parts = {:pages => matches[1]}
    parts[:reference] = ReferenceParser.parse string[matches.end(0)..-1].strip
    parts
  end

end
