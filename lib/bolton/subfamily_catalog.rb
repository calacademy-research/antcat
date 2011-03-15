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
#  This generates info/bolton_subfamily_catalog.info
#
# Manual edits:
#   03. FORMICOMORPHS     Made Johnia bold
#   03. FORMICOMORPHS     Made Pseudocamponotus bold and removed bold in taxonomic history
#   04. MYRMECIOMORPHS    Remove 'Genus' from 'Genus MYRMECIITES'
#   06. ECTAHETEROMORPHS  Removed italics from Stictoponerini
#   07. MYRMICOMORPHS 1   Corrected 'Adelomymex' to 'Adelomyrmex'
#   07. MYRMICOMORPHS 1   Added Formosimyrma to Solenopsidini genera list
#   08. MYRMICOMORPHS 2   Removed italics from 'PHEIDOLINI' in junior synonyms header
#   08. MYRMICOMORPHS 2   Corrected 'Quinqueangulicapito' to 'Quineangulicapito'
#   09. PONEROMORPHS      Added Probolomyrmex to Probolomyrmecini genus list
#   10. EXTINCT SUBFAMS   Removed italics from Specomyrminae family_group_line

require 'bolton/subfamily_catalog_family'
require 'bolton/subfamily_catalog_subfamily'
require 'bolton/subfamily_catalog_tribe'
require 'bolton/subfamily_catalog_genus'
require 'bolton/subfamily_catalog_subgenus'

class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def import
    Taxon.delete_all

    parse_family
    parse_supersubfamilies 

  ensure
    super
    Progress.puts "#{Subfamily.count} subfamilies, #{Tribe.count} tribes, #{Genus.count} genera, #{Subgenus.count} subgenera, #{Species.count} species"
  end

  def parse_supersubfamilies
    while parse_supersubfamily; end
  end

  def parse_supersubfamily
    return unless @type
    Progress.info 'parse_supersubfamily'
    expect :supersubfamily_header
    parse_next_line

    parse_genera_lists :supersubfamily

    while parse_subfamily; end
    true
  end

  private
  def parse_taxonomic_history
    Progress.info 'parse_taxonomic_history'
    taxonomic_history = ''
    loop do
      parse_next_line
      break if @type != :other
      taxonomic_history << @paragraph
    end
    taxonomic_history
  end

  def parse_references
    Progress.info 'parse_references'
    parsed_text = ''
    parsed_text << parse_taxonomic_history if @type == :other
    parsed_text
  end

  def get_filenames filenames
    super filenames.select {|filename| File.basename(filename) =~ /^\d\d\. /}
  end

  def grammar
    Bolton::SubfamilyCatalogGrammar
  end

end
