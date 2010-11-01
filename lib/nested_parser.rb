module NestedParser

  def self.parse string
    return unless string.present?

    matches = string.match /^(Pp\. \d+-\d+ in:?)\s*/
    return unless matches.present?

    {:nested => ReferenceParser.parse(string[matches.end(0)..-1].strip).merge(:pages_in => matches[1])}
  end

end
