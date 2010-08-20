class BoltonReference < ActiveRecord::Base
  set_table_name 'bolton_refs'

#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

  def self.import(filename, show_progress = false)
    $stderr.print "Importing #{filename}" if show_progress
    doc = Nokogiri::HTML(File.read(filename))
    ps = doc.css('p')
    ps.each do |p|
      s = p.inner_html
      $stderr.print '.' if show_progress

      s = s.gsub(/\n/, ' ').strip
      s = s.gsub(/<.+?>/, '')
      s = CGI.unescapeHTML(s)

      next unless s.length > 20

      s, date = extract_date s

      match = s.match /(\D+) ?(\d\w+)\.? ?(.+)[,.](?: \[(.+)\])?/

      unless match && match.size >= 4
        puts
        puts s
        puts match
        next
      end

      authors = match[1].strip
      year = match[2].strip
      title_and_citation = match[3].strip

      reference = BoltonReference.create! :authors => authors, :year => year, :title_and_citation => title_and_citation, :date => date

    end
    $stderr.puts if show_progress
  end

  def self.extract_date s
    parts = s.split(/ ?\[([^\]]+)\]$/)
    return s, nil unless parts.length == 2
    return parts
  end

  def match
    Reference.all.find do |reference|
      reference.authors = authors &&
      reference.year = year &&
      reference.title + '. ' + reference.citation = title_and_citation
    end
  end
end
