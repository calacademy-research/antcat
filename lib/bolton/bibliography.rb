#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

class Bolton::Bibliography
  def initialize filename, record_and_show_progress = false
    Progress.init record_and_show_progress
    @filename = filename.to_s
    @success_count = 0
  end

  def import_file
    Progress.puts "Importing #{@filename}..."
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
      reference = import_reference line
      record_and_show_progress reference
    end
    show_results
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
    Bolton::Reference.create! Bolton::ReferenceGrammar.parse(string).value
  rescue Citrus::ParseError => e
    puts e
  end

  def record_and_show_progress reference
    Progress.tally
    @success_count += 1 if reference
    return unless Progress.processed_count % 100 == 0
    show_progress
  end

  def show_progress
    Progress.puts "#{@success_count}/#{Progress.processed_count} parsed (#{Progress.percent @success_count}) in #{Progress.elapsed} (#{Progress.rate})"
  end

  def show_results
    Progress.puts
    show_progress
  end

end
