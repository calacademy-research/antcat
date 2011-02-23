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

class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def import
    Taxon.delete_all
    while @line
      parse_subfamily || parse_genus || parse_next_line
    end
    super
  end

  def parse_subfamily
    return unless @type == :subfamily

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history
    Subfamily.create! :name => name, :status => 'valid', :fossil => fossil, :taxonomic_history => taxonomic_history
  end

  def parse_genus
    return unless @type == :genus

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history
    Genus.create! :name => name, :status => 'valid', :fossil => fossil, :taxonomic_history => taxonomic_history
  end

  def parse_taxonomic_history
    taxonomic_history = ''
    loop do
      parse_next_line
      break if !@line || @type != :other
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
