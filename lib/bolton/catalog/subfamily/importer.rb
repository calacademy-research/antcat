# coding: UTF-8
#  A Bolton subfamily catalog file is named NN. NAME.docx,
#    e.g. 01. FORMICIDAE.docx
#  and yes, the first one is actually for the whole family, rather
#  than a 'supersubfamily' (which is what I call a group of subfamilies)
#
#  To convert a subfamily catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:subfamilies

require 'bolton/catalog/subfamily/family_importer'
require 'bolton/catalog/subfamily/genus_importer'
require 'bolton/catalog/subfamily/subfamily_importer'
require 'bolton/catalog/subfamily/subgenus_importer'
require 'bolton/catalog/subfamily/tribe_importer'

class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  def import
    Taxon.delete_all
    Protonym.delete_all
    Citation.delete_all
    ForwardReference.delete_all
    MissingReference.delete_all

    parse_family
    #parse_supersubfamilies
    ForwardReference.fixup
  ensure
    super
    Progress.puts "#{::Subfamily.count} subfamilies, #{::Tribe.count} tribes, #{::Genus.count} genera, #{::Subgenus.count} subgenera, #{::Species.count} species"
  end

  def parse_supersubfamilies
    while parse_supersubfamily; end
  end

  def parse_supersubfamily
    return unless @type
    Progress.method
    consume :supersubfamily_header

    parse_genera_lists :supersubfamily

    while parse_subfamily; end

    parse_genera_incertae_sedis :genera_incertae_sedis_in_poneroid_subfamilies_header

    true
  end

  def get_file_names file_names
    selected = file_names.select do |file_name|
      base_name = File.basename(file_name)
      numeric_prefix = base_name.match /^(\d\d). /
      numeric_prefix #&& (number = numeric_prefix[1].to_i) && (number == 1 || number >= 9)
    end
    super selected
  end

  def grammar
    Bolton::Catalog::Subfamily::Grammar
  end

  def parse_taxonomic_history item_type
    taxonomic_history = @paragraph
    parsed_taxonomic_history = []
    if @type == :taxonomic_history_header
      parse_next_line item_type
      while @type == item_type || @type == :texts do
        if @type == :texts
          @parse_result = @parse_result.merge :type => item_type
          @type = item_type
          Progress.info "  reparsed as #{item_type}" if @show_parsing
        end
        taxonomic_history << @paragraph
        parsed_taxonomic_history << @parse_result
        parse_next_line item_type
      end
    end
    return taxonomic_history, parsed_taxonomic_history
  end

  def parse_references_sections *allowed_header_types
    parsed_text = ''
    while allowed_header_types.include? @type
      parsed_text << parse_references_section
      parse_next_line
    end
    parsed_text
  end

  def parse_references_section
    parsed_text = @paragraph
    parse_next_line :text
    parsed_text << @paragraph
    parsed_text
  end

end
