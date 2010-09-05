class BoltonReference < ActiveRecord::Base
  belongs_to :ward_reference

#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

  def self.import filename, show_progress = false
    @show_progress = show_progress

    $stderr.print "Importing #{filename}" if @show_progress
    doc = Nokogiri::HTML(File.read(filename))
    ps = doc.css('p')
    ps.each do |p|
      import_reference p.inner_html
    end
    $stderr.puts if @show_progress
  end

  def self.import_reference s
    $stderr.print '.' if @show_progress

    s = normalize s
    return unless s.length > 20

    s, date = extract_date s

    match = s.match /(\D+) ?(\d\w+)\.? ?(.+)[,.]/

    authors = match[1].strip
    year = match[2].strip
    title_and_citation = match[3].strip

    reference = BoltonReference.create! :authors => authors, :year => year, :title_and_citation => title_and_citation, :date => date
  end

  def self.extract_date s
    parts = s.split(/ ?\[([^\]]+)\]$/)
    return s, nil unless parts.length == 2
    return parts
  end

  def self.normalize s
    s = s.gsub(/\n/, ' ').strip
    s = s.gsub(/<.+?>/, '')
    s = CGI.unescapeHTML(s)
  end

  def self.match_against_ward show_progress = false
    BoltonReferenceMatcher.new(show_progress).match_all
  end

  def to_s
    "#{authors} #{year}. #{title_and_citation}."
  end
end
