module JournalParser

  def self.parse string
    matches = string.match(/(.+?)(\S+)$/) or return
    journal_title = matches[1]
    string[0, journal_title.length] = ''
    journal_title.strip
  end

end
