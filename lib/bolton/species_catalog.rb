#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use
#  1) Open the file in Word
#  2) Save it as web page

#  To import these files, run
#    rake import_species

class Bolton::SpeciesCatalog
  def initialize show_progress = false
    Progress.init show_progress
    @success_count = 0
  end

  def clear
    Species.delete_all
  end

  def import_files filenames
    filenames.each do |filename|
      @filename = filename
      Progress.puts "Importing #{@filename}..."
      import_html File.read @filename
      Progress.show_results
      Progress.puts
    end
    Progress.show_results
  end

  def import_html html
    doc = Nokogiri::HTML html
    @genus = nil
    ps = doc.css('p')
    ps.each do |p|
      record = parse p.inner_html
      case record[:type]
      when :genus then @genus = record[:genus]
      when :species then import_species record
      end
    end
  end

  def parse string
    string = string.gsub /\n/, ' '
    Bolton::SpeciesCatalogGrammar.parse(string).value
  rescue Citrus::ParseError => e
    p e
    nil
  end

  def import_species record
    Species.create! :name => "#{@genus} #{record[:species]}"
    Progress.tally_and_show_progress 100
  end

end
