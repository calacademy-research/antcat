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
    @not_understood_count = 0
  end

  def import_files filenames
    Taxon.delete_all
    filenames.each do |filename|
      Progress.puts "Importing #{@filename}..."
      import_html File.read filename
    end
    show_results
  end

  def import_html html
    Nokogiri::HTML(html).css('p').each do |p|
      record = Bolton::GenusCatalogParser.parse p.inner_html
      if record[:type] == :not_understood
        @not_understood_count += 1
        next
      end
      record[:genus][:taxonomic_history] = p.to_html.strip

      subfamily_name = record[:genus].delete(:subfamily)
      tribe_name = record[:genus].delete(:tribe)

      subfamily = subfamily_name && Subfamily.find_or_create_by_name(subfamily_name)
      tribe = tribe_name && Tribe.find_or_create_by_name(tribe_name, :parent => subfamily)

      genus = Genus.find_or_create_by_name record[:genus].merge :parent => tribe || subfamily

      Progress.tally
    end
  end

  def show_results
    Progress.show_results
    Progress.puts "(#{@not_understood_count} sections not understood)"
  end

end
