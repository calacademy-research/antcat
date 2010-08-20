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
      string_similarity(remove_punctuation(reference.title + reference.citation), remove_punctuation(title_and_citation)) > 0.85
    end
  end

  def remove_punctuation s
    s.gsub(/\W/, '')
  end

  def string_similarity str1, str2
    str1.downcase! 
    pairs1 = (0..str1.length-2).collect {|i| str1[i,2]}.reject {
      |pair| pair.include? " "}
    str2.downcase! 
    pairs2 = (0..str2.length-2).collect {|i| str2[i,2]}.reject {
      |pair| pair.include? " "}
    union = pairs1.size + pairs2.size 
    intersection = 0 
    pairs1.each do |p1| 
      0.upto(pairs2.size-1) do |i| 
        if p1 == pairs2[i] 
          intersection += 1 
          pairs2.slice!(i) 
          break 
        end 
      end 
    end 
    (2.0 * intersection) / union
  end
end
