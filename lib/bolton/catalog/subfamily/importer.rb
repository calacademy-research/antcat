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
#   03. FORMICOMORPHS     Made Pseudocamponotus bold and removed bold in taxonomic history. Made 'Pseudocamponotus' in line in taxonomic
#                         history nonbold
#   03. FORMICOMORPHS     Made WILSONIA brown at the end of the document, as it is indeed a homonym of a bird genus
#   04. MYRMECIOMORPHS    Remove 'Genus' from 'Genus MYRMECIITES'
#   06. ECTAHETEROMORPHS  Removed italics from Stictoponerini
#   07. MYRMICOMORPHS 1   Corrected 'Adelomymex' to 'Adelomyrmex'
#   07. MYRMICOMORPHS 1   Corrected 'origional' to 'original' (new)
#   07. MYRMICOMORPHS 1   Added Formosimyrma to Solenopsidini genera list
#   07. MYRMICOMORPHS 1   Corrected 'Quinqueangulicapito' to 'Quineangulicapito'
#   08. MYRMICOMORPHS 2   Removed italics from 'PHEIDOLINI' in junior synonyms header
#   09. PONEROMORPHS      Added Probolomyrmex to Probolomyrmecini genus list
#   11. EXTINCT SUBFAMS   Removed italics from Sphecomyrminae family_group_line

require 'bolton/catalog/subfamily/family_importer'
require 'bolton/catalog/subfamily/genus_importer'
require 'bolton/catalog/subfamily/subfamily_importer'
require 'bolton/catalog/subfamily/subgenus_importer'
require 'bolton/catalog/subfamily/tribe_importer'

class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
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
    Bolton::Catalog::Subfamily::Grammar
  end

end
