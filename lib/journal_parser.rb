module JournalParser

  def self.parse string
    matches = string.match(/(.+?)(\S+)$/) or return
    journal_name = matches[1]
    string[0, journal_name.length] = ''
    journal_name.strip
  end

end
