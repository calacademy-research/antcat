# coding: UTF-8
#  A Bolton subfamily catalog file is named NN. NAME.docx,
#    e.g. 01. FORMICIDAE.docx
#  and yes, the first one is actually for the whole family, rather
#  than a 'supersubfamily' (group of subfamilies)
#
#  To convert a subfamily catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:subfamilies

require_relative 'family_importer'
require_relative 'genus_importer'
require_relative 'subfamily_importer'
require_relative 'subgenus_importer'
require_relative 'tribe_importer'

class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer
  private

  def import
    Taxon.delete_all

    parse_family
    parse_supersubfamilies

  ensure
    super
    Progress.puts "#{::Subfamily.count} subfamilies, #{::Tribe.count} tribes, #{::Genus.count} genera, #{::Subgenus.count} subgenera, #{::Species.count} species"
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
    filenames = filenames.select do |filename|
      if matches = File.basename(filename).match(/^(\d\d)\. /)
        number = matches[1].to_i
      end
    end
    super filenames
  end

  def grammar
    Importers::Bolton::Catalog::Subfamily::Grammar
  end

end
