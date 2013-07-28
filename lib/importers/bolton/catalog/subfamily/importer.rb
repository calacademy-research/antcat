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

class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer
  def import

    Update.delete_all

    self.class.do_manual_prefixups unless Rails.env.test?

    parse_family
    parse_supersubfamilies

    do_manual_fixups unless Rails.env.test?

    #resolve_parent_synonyms

  ensure
    super
    Progress.puts "#{::Subfamily.count} subfamilies, #{::Tribe.count} tribes, #{::Genus.count} genera, #{::Subgenus.count} subgenera, #{::Species.count} species"
    Progress.puts "#{Update.count} updates"
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

    parse_genera_incertae_sedis 'subfamily', {}, :genera_incertae_sedis_in_poneroid_subfamilies_header

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
      #numeric_prefix
      numeric_prefix #&& (number = numeric_prefix[1].to_i) && (number == 1 || number == 7 || number == 8)
    end
    super selected
  end

  def grammar
    Importers::Bolton::Catalog::Subfamily::Grammar
  end

  def parse_history genus_name = nil
    Progress.method
    taxts = []
    if @type == :history_header
      loop do
        parse_next_line
        convert_ponerites_headline_to_text
        break unless @type == :texts
        item = Importers::Bolton::Catalog::TextToTaxt.convert @parse_result[:texts], genus_name
        if item.present?
          taxts << item if item.present?
        else
          Progress.error "Blank taxonomic history item: #{@line}"
        end
      end
    end
    taxts
  end

  def convert_ponerites_headline_to_text
    if @type == :genus_headline && @parse_result[:protonym].try(:[], :genus_name) == 'Ponerites'
      @parse_result = {texts: [grammar.parse(@line, root: :text).value]}
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
    title = convert_line_to_taxt @line
    parse_next_line
    references = Importers::Bolton::Catalog::TextToTaxt.convert @parse_result[:texts], taxon.name.to_s
    taxon.reference_sections.create! title_taxt: title, references_taxt: references
  end

  ###########
  def self.do_manual_prefixups
    fix_reference 123310, 'Buckley 1866'
    fix_reference 133054, 'Bolton Fisher 2012'
  end

  def set_unresolved_homonym name
    taxon = Taxon.find_by_name name
    return unless taxon.present?
    taxon.update_attribute :unresolved_homonym, true
  end

  def do_manual_fixups
    delete_subgenus 'Atopogyne'
    delete_subgenus 'Colobocrema'
    delete_subgenus 'Oxygyne'
    delete_subgenus 'Physocrema'
    delete_subgenus 'Xiphocrema'
    delete_subgenus 'Nematocrema'
    delete_subgenus 'Paracrema'
    delete_subgenus 'Sphaerocrema'
    set_status_manually 'Wilsonia', 'unresolved homonym'

    set_unresolved_homonym 'Hypochira'

    set_status_manually 'Formicium', 'collective group name'
    set_synonym_of_orthocrema 'Apterocrema'
    set_synonym_of_orthocrema 'Eucrema'
    set_synonym_of_orthocrema 'Mesocrema'
    set_synonym_of_orthocrema 'Neocrema'
    set_synonym_of_orthocrema 'Rhachiocrema'
  end

  def set_synonym_of_orthocrema subgenus
    junior = Taxon.find_name "Crematogaster (#{subgenus})"
    senior = Taxon.find_name "Crematogaster (Orthocrema)"
    junior.first.become_junior_synonym_of senior.first
  end

  def self.fix_reference id, bolton_key_cache
    reference = Reference.find_by_id id
    return unless reference
    reference.bolton_key_cache = bolton_key_cache
    reference.save!
  end

  def delete_subgenus name
    subgenus = Subgenus.where("name_cache LIKE '%(#{name})'").first
    return unless subgenus.present?
    subgenus.destroy
    Progress.log "Deleted subgenus '#{subgenus.name}'"
  end

end
