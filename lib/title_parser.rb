module TitleParser

  def self.parse string
    title = nil
    return title if title = find_string_before_pages_in(string)

    colon_index = string.index ':'
    string_before_colon = string[0, colon_index - 1]

    match = string.match /(^.*?)\.\s*/
    string[0, match[0].length] = ''
    match[1]
  end

  private
  def self.find_string_before_pages_in string
    period_index = nil
    string.length.times do |index|
      if string[index, 1] == '.'
        period_index = index
        next
      end

      pages_in = PagesInGrammar.parse string[index..-1] rescue nil
      if pages_in
        title = string[0, period_index]
        string[0, index] = ''
        return title
      end
    end
    nil
  end

end
