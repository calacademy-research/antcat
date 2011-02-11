#  The Bolton genus catalog files are NGC-GEN.A-L.docx and NGC-GEN.M-Z.docx.

#  To convert a genus catalog file from Bolton to a format we can use
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:genera

class Bolton::GenusCatalog
  def initialize show_progress = false
    Progress.init show_progress
    Progress.open_log 'log/bolton_genus_import.log'
  end

  def import_files filenames
    Taxon.delete_all
    filenames.each do |filename|
      Progress.puts "Importing #{filename}..."
      import_html File.read filename
    end
    show_results
  end

  def import_html html
    Nokogiri::HTML(html).css('p').each do |p|
      record = Bolton::GenusCatalogParser.parse p.inner_html

      case record[:type]
      when :blank then next
      when :subgenus then next
      when :not_understood then next
      end

      subfamily_name = record[:subfamily]
      tribe_name = record[:tribe]

      subfamily = subfamily_name && Subfamily.find_or_create_by_name(subfamily_name)
      tribe = tribe_name && Tribe.find_or_create_by_name(tribe_name, :subfamily => subfamily)

      Genus.find_or_create_by_name record[:name], :fossil => record[:fossil], :status => record[:status].to_s, :tribe => tribe, :subfamily => subfamily,
        :taxonomic_history => p.to_html.strip

      Progress.tally
    end
  end

  def show_results
    Progress.show_results
  end

end
