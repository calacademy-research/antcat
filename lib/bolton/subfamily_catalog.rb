#  A Bolton subfamily catalog file is named NN. NAME.docx,
#    e.g. 01. FORMICIDAE.docx
#  and yes, the first one is actually for the whole family, rather
#  than s 'supersubfamily' (group of subfamilies)
#
#  To convert a subfamily catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:subfamilies
#  This generates log/bolton_subfamily_catalog.log
#
# Manual edits:
#   07. MYRMICOMORPHS 1.htm Corrected 'Adelomymex' to 'Adelomyrmex'

require 'bolton/subfamily_catalog_family'
require 'bolton/subfamily_catalog_subfamily'

class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def import
    Taxon.delete_all

    begin
      parse_family
      parse_supersubfamilies 
    rescue Exception => e
      Progress.error e.message
    end
    super
    Progress.puts "#{Subfamily.count} subfamilies, #{Tribe.count} tribes, #{Genus.count} genera, #{Subgenus.count} subgenera, #{Species.count} species"
  end

  def parse_supersubfamilies
    while parse_supersubfamily; end
  end

  def parse_supersubfamily
    return unless @type == :supersubfamily_header
    parse_next_line
    while parse_subfamily; end
    true
  end

  private
  def parse_genus attributes = {}
    name = @parse_result[:name]
    status = @parse_result[:status]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history
    genus = Genus.find_by_name name
    if genus
      attributes = {:status => status, :taxonomic_history => taxonomic_history}.merge(attributes)
      check_status_change genus, attributes[:status]
      raise "Genus #{name} fossil change from #{genus.fossil?} to #{fossil}" if fossil != genus.fossil
      genus.update_attributes attributes
    else
      check_existence name, genus
      Genus.create!({:name => name, :fossil => fossil, :status => status, :taxonomic_history => taxonomic_history}.merge(attributes))
    end
  end

  def check_status_change genus, status
    raise "Genus #{genus.name} status change from #{genus.status} to #{status}" if status != genus.status unless genus.name == 'Hypochira'
  end

  def check_existence name, genus
    raise "Genus #{name} not found" unless genus || name == 'Syntaphus'
  end

  def parse_taxonomic_history
    taxonomic_history = ''
    loop do
      parse_next_line
      break if @type != :other
      taxonomic_history << @paragraph
    end
    taxonomic_history
  end

  def get_filenames filenames
    super filenames.select {|filename| File.basename(filename) =~ /^\d\d\. /}
  end

  def grammar
    Bolton::SubfamilyCatalogGrammar
  end

end
