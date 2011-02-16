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

      save_genus record.merge :taxonomic_history => p.to_html.strip

      Progress.tally
    end
  end

  def save_genus record

    subfamily_name = record[:subfamily]
    tribe_name = record[:tribe]
    synonym_of_name = record[:synonym_of]
    homonym_of_name = record[:homonym_of]

    subfamily = subfamily_name && Subfamily.find_or_create_by_name(subfamily_name, :status => 'valid')
    raise if subfamily && !subfamily.valid?

    tribe = tribe_name && Tribe.find_or_create_by_name(tribe_name, :subfamily => subfamily, :status => 'valid')
    raise if tribe && !tribe.valid?

    synonym_of = synonym_of_name && Genus.find_or_create_by_name(synonym_of_name, :status => 'valid')
    raise if synonym_of && !synonym_of.valid?

    homonym_of = homonym_of_name && Genus.find_or_create_by_name(homonym_of_name, :status => 'valid')
    raise if homonym_of && !homonym_of.valid?

    genus = Genus.find_or_create_by_name record[:name],
      :fossil => record[:fossil], :status => record[:status].to_s,
      :subfamily => subfamily, :tribe => tribe, 
      :synonym_of => synonym_of, :homonym_of => homonym_of,
      :taxonomic_history => record[:taxonomic_history]
    raise unless genus.valid?
  end

  def show_results
    Progress.show_results
  end

end
