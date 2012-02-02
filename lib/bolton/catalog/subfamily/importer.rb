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

require_relative 'family_importer'
require_relative 'genus_importer'
require_relative 'subfamily_importer'
require_relative 'subgenus_importer'
require_relative 'tribe_importer'

class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  def import
    Taxon.delete_all
    Protonym.delete_all
    Citation.delete_all
    ForwardReference.delete_all
    MissingReference.delete_all

    parse_family
    parse_supersubfamilies

    do_manual_fixups
    ForwardReference.fixup
    resolve_parent_synonyms

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

    parse_genera_lists

    while parse_subfamily; end

    #parse_genera_incertae_sedis :poneroid_subfamilies, :genera_incertae_sedis_in_poneroid_subfamilies_header

    true
  end

  def resolve_parent_synonyms
    any_changes = true
    while any_changes 
      any_changes = false
      Taxon.all.each do |taxon|
        if taxon.respond_to? :tribe
          # if a taxon's tribe is a synonym, set the taxon's tribe to the thing it's a synonym of
          tribe = taxon.tribe
          next unless tribe && tribe.synonym?
          taxon.update_attribute :tribe, tribe.synonym_of
          Progress.log "Changed tribe of #{taxon.name} from #{tribe.name} to #{taxon.tribe.name}"
          any_changes = true
        end
        if taxon.respond_to? :subgenus
          subgenus = taxon.subgenus
          next unless subgenus && subgenus.synonym?
          taxon.update_attribute :subgenus, subgenus.synonym_of
          Progress.log "Changed subgenus of #{taxon.name} from #{subgenus.name} to #{taxon.subgenus.name}"
          any_changes = true
        end
      end
    end
  end

  def get_file_names file_names
    selected = file_names.select do |file_name|
      base_name = File.basename(file_name)
      numeric_prefix = base_name.match /^(\d\d). /
      numeric_prefix && (number = numeric_prefix[1].to_i) && (number == 1 || number <= 6)
    end
    super selected
  end

  def grammar
    Bolton::Catalog::Subfamily::Grammar
  end

  def parse_taxonomic_history
    Progress.method
    parsed_taxonomic_history = []
    if @type == :taxonomic_history_header
      loop do
        parse_next_line
        convert_ponerites_headline_to_text
        break unless @type == :texts
        parsed_taxonomic_history << Bolton::Catalog::TextToTaxt.convert(@parse_result[:texts])
      end
    end
    parsed_taxonomic_history
  end

  def convert_ponerites_headline_to_text
    if @type == :genus_headline && @parse_result[:protonym].try(:[], :genus_name) == 'Ponerites'
      @parse_result = grammar.parse(@line, root: :text).value
      @type = :texts
    end
  end

  def parse_reference_sections taxon, *allowed_header_types
    while allowed_header_types.include? @type
      parse_reference_section taxon
      parse_next_line
    end
  end

  def parse_reference_section taxon
    texts = Bolton::Catalog::Grammar.parse(@line, root: :text).value
    title = Bolton::Catalog::TextToTaxt.convert texts[:text]
    parse_next_line
    references = Bolton::Catalog::TextToTaxt.convert @parse_result[:texts]
    taxon.reference_sections.create! title: title, references: references
  end

  def do_manual_fixups
    wilsonia = Genus.find_by_name 'Wilsonia'
    wilsonia.update_attribute :status, Status['unresolved homonym'].to_s rescue nil
  end

end
