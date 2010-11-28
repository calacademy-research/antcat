#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

class Bolton::Bibliography
  def initialize filename, show_progress = false
    Progress.init show_progress
    @filename = filename.to_s
  end

  def import_file
    Progress.print "Importing #{@filename}"
    import_html File.read(@filename)
    Progress.puts
  end

  def import_html html
    doc = Nokogiri::HTML html
    ps = doc.css('p')
    ps.each do |p|
      line = p.inner_html
      next if header? line
      next if blank? line
      import_reference line
    end
  end

  def header? line
    line =~ /CATALOGUE REFERENCES/
  end

  def blank? line
    line.length < 20
  end

  def import_reference string
    string = CGI.unescapeHTML(string)
    string.gsub! /&nbsp;/, ' '
    string.gsub! /\n/, ' '
    result = Bolton::ReferenceGrammar.parse(string)

    attributes = Bolton::ReferenceGrammar.parse(string).value
    Bolton::Reference.create! attributes
    Progress.dot
  end

end
