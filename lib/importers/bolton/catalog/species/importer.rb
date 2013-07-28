# coding: UTF-8
class Importers::Bolton::Catalog::Species::Importer < Importers::Bolton::Catalog::Importer

  def initialize options = {}
    ForwardRef.delete_all
    DedupeSynonyms.dedupe

#Update.destroy_all

    @options = options.reverse_merge show_progress: false
    @continue_after_parse_error = true
    @return_blank_lines = false
    super @options[:show_progress]

    do_manual_prefixups

    Progress.total_count = 25870
  end

  def import
    @genus_headers_count = @genera_not_found_count = @duplicate_genera_that_need_resolving_count =
      @species_count = @error_count = @ignored_count = 0
    import_lines
    do_manual_fixups unless Rails.env.test?
    finish_importing
    show_results
  end

  def import_lines
    while @line
      case @type
      when :not_understood
        @error_count += 1
      when :note
        @genus.update_attribute :genus_species_header_notes_taxt, convert_line_to_taxt(@parse_result[:text]) if @genus
      when :catalog_header, :genus_see_under, :species_see_under
        @ignored_count += 1
      when :genus_header
        @genus_headers_count += 1
        find_matching_genus_names
      when :species_record
        if @genus
          species = import_taxon
          Progress.info "Imported #{species.inspect}"
          @species_count += 1
        elsif @parse_result[:species_group_epithet] != 'heerii'
          Progress.error "Species with no active genus: #{@line}"
        end
      else raise "Unexpected type: #{@type}"
      end
      parse_next_line
    end
  end

  def import_taxon
    Species.import(
      species_epithet: @parse_result[:species_group_epithet],
      fossil: @parse_result[:fossil] || false,
      status: @parse_result[:status] || 'valid',
      genus: @genus,
      protonym: @parse_result[:protonym],
      raw_history: @parse_result[:history],
      history: self.class.convert_history_to_taxts(@parse_result[:history], @genus.name, @parse_result[:species_group_epithet])
    )
  end

  def find_matching_genus_names
    @genus = nil
    matching_genus_names = Genus.with_names.where "name = '#{@parse_result[:name]}'"
    matching_genus_names.keep_if {|e| not e.invalid?} if matching_genus_names.count > 1
    if matching_genus_names.empty? and @parse_result[:name] != 'Myrmicium'
      Progress.error "Genus '#{@parse_result[:name]}' did not exist"
      @genera_not_found_count += 1
    elsif matching_genus_names.size > 1
      Progress.error "More than one genus '#{@parse_result[:name]}'"
      @duplicate_genera_that_need_resolving_count += 1
    else
      @genus = matching_genus_names.first
    end
  end

  #############
  def do_manual_prefixups
    good_reference = Reference.find_by_id 123814
    return unless good_reference
    taxon_with_bad_reference = Taxon.find_by_name_cache 'Plagiolepis breviscapa'
    return unless taxon_with_bad_reference
    taxon_with_bad_reference.protonym.authorship.update_attribute :reference, good_reference
  end

  def finish_importing
    Progress.print 'Fixing up names...'
    ForwardRef.fixup
    do_manual_fixups_after_fixups unless Rails.env.test?
    Progress.puts
  end

  def set_unidentifiable name
    taxon = Taxon.find_by_name name
    return unless taxon.present?
    taxon.update_attribute :status, 'unidentifiable'
  end

  def do_manual_fixups_after_fixups
    set_status_manually 'Camponotus abdominalis', 'homonym'
    set_status_manually 'Camponotus (Camponotus) herculeanus var. rubens', 'synonym'
    self.class.set_synonym 'Camponotus (Camponotus) herculeanus rubens', 'Camponotus novaeboracensis'
    self.class.set_synonym 'Formica occidua', 'Formica moki'
    self.class.set_synonym 'Solenopsis wagneri', 'Solenopsis invicta'
    self.class.set_synonym 'Prionopelta poultoni', 'Prionopelta majuscula'
    set_status_manually 'Camponotus pallens', 'homonym', 1
    fix_nomen_nudum_in_brackets
    fix_formica_whymperi
    fix_diacamma_sculpta
    fix_guppyi
    fix_spinipes
  end

  def make_species_into_subspecies
    species = Species.find_by_name 'Crematogaster smithi'
    if species
      new_parent_species = Species.find_by_name 'Crematogaster minutissima'
      if new_parent_species
        species.become_subspecies_of new_parent_species
      end
    end

    set_status_manually 'Formica rufa ravida', 'valid'
  end

  def fix_guppyi
    guppyi = Taxon.find_by_name('Camponotus guppyi') or raise
    correct_reference = Reference.find_by_bolton_key_cache('Mann 1919') or raise
    guppyi.protonym.authorship.update_attribute :reference, correct_reference
  end

  def fix_spinipes
    spinipes = Taxon.find_by_name 'Aphaenogaster spinipes'
    return unless spinipes

    # set name
    correct_name = Name.find_by_name 'Aphaenogaster swammerdami spinipes'
    spinipes.update_attribute :name_id, correct_name.id

    # delete first 3 history items
    3.times {|i| spinipes.history_items.first.destroy}

    # set type
    Taxon.connection.execute %{UPDATE taxa SET type = 'Subspecies' WHERE id = '#{spinipes.id}'}
    spinipes = Taxon.find spinipes.id

    # set species
    species = Taxon.find_by_name 'Aphaenogaster swammerdami'
    spinipes.update_attribute :species_id, species.id

    # change protonym name
    protonym_name = spinipes.protonym.name
    new_protonym_html = protonym_name.protonym_html + '[sic] var. <i>spinipes</i>'
    protonym_name.update_attribute :protonym_html, new_protonym_html

    # fix locality
    protonym = spinipes.protonym
    protonym.locality = 'Madagascar'
    protonym.save!

    # fix authorship
    reference = Reference.find_by_bolton_key_cache 'Santschi 1911e'
    protonym.authorship = Citation.create! reference: reference, pages: '123', forms: 'w.'
    protonym.save!
  end

  def self.set_synonym junior, senior
    junior = Taxon.find_by_name junior
    senior = Taxon.find_by_name senior
    junior.become_junior_synonym_of senior
  rescue
  end

  def fix_formica_whymperi
    whymperi = Taxon.find_by_name 'Formica whymperi'
    return unless whymperi
    adamsi_whymperi_name = Name.find_by_name 'Formica adamsi whymperi'
    return unless adamsi_whymperi_name
    adamsi = Taxon.find_by_name 'Formica adamsi'
    whymperi.update_attributes species_id: adamsi.id, name_id: adamsi_whymperi_name.id
  end

  def fix_diacamma_sculpta
    sculpta = Taxon.find_by_name 'Diacamma sculpta'
    return unless sculpta
    rugosum_sculptum_name = Name.find_by_name 'Diacamma rugosum sculptum'
    return unless rugosum_sculptum_name
    rugosum = Taxon.find_by_name 'Diacamma rugosum'
    sculpta.update_attributes species_id: rugosum.id, name_id: rugosum_sculptum_name.id
  end

  def do_manual_fixups
    set_status_manually 'Temnothorax foreli', 'homonym', 1
    set_status_manually 'Temnothorax manni', 'homonym', [1, 2]
    set_status_manually 'Tetramorium pauper', 'homonym', 1
    set_status_manually 'Camponotus abdominalis', 'valid'
    set_status_manually 'Camponotus (Camponotus) herculeanus rubens', 'valid'
    set_status_manually 'Camponotus terebrans', 'valid'
    set_status_manually 'Ectatomma permagnum', 'valid'
    Taxon.with_names.where(['name = ?',  'Attaichnus kuenzelii']).update_attribute :ichnotaxon, true
    set_status_manually 'Myrmeciites goliath', 'collective group name'
    set_status_manually 'Myrmeciites herculeanus', 'collective group name'
    set_status_manually 'Myrmeciites tabanifluviensis', 'collective group name'
    set_status_manually 'Paraprionopelta minima', 'valid'
    set_status_manually 'Formica strangulata', 'valid'
    set_status_manually 'Aphaenogaster picena', 'valid'
    Citation.connection.execute "UPDATE citations SET reference_id = 130850 WHERE id = 174187"
    make_species_into_subspecies
    Species.import_myrmicium_heerii
    fix_creightonidris
    replace_references
    self.class.fix_pheidole_longipes
    self.class.fix_polyrhachis
    set_status_manually 'Strongylognathus kratochvili', 'valid'
  end

  def self.fix_pheidole_longipes
    update_status 'Pheidole longipes', 'Pergande 1896', 'homonym'
  end

  def self.become_subspecies_of subspecies, species
    taxon = Taxon.find_by_name subspecies
    return unless taxon
    species = Taxon.find_by_name species
    return unless species
    taxon.become_subspecies_of species
  end

  def self.fix_polyrhachis
    become_subspecies_of 'Polyrhachis overbecki', 'Polyrhachis thrinax'
    become_subspecies_of 'Polyrhachis javaniana', 'Polyrhachis sculpturata'
    become_subspecies_of 'Polyrhachis exflavicornis', 'Polyrhachis bicolor'
  end

  def self.update_status name, bolton_key_cache, status
    taxon = Taxon.search_for_name_and_authorship name, bolton_key_cache
    taxon.update_attribute :status, status if taxon
    taxon
  end

  def replace_reference old_bolton_key_cache, new_key_cache
    reference = Reference.find_by_bolton_key_cache old_bolton_key_cache
    return unless reference
    replacement = Reference.find_by_key_cache new_key_cache
    return unless replacement
    reference.replace_with replacement
  end

  def replace_references
    replace_reference 'Sarnat Economo 2012', 'Marcus, 1953'
    replace_reference 'Willey Brown 1983', 'Willey, R. B.; Brown, W. L., Jr.'
  end

  def fix_creightonidris
    ceratobasis = Taxon.find_by_name 'Ceratobasis'
    basiceros = Taxon.find_by_name 'Basiceros'
    creightonidris = Taxon.find_by_name 'Creightonidris'
    aspididris = Taxon.find_by_name 'Aspididris'

    creightonidris.become_not_junior_synonym_of ceratobasis
    creightonidris.become_junior_synonym_of basiceros

    aspididris.become_not_junior_synonym_of ceratobasis
    aspididris.become_junior_synonym_of basiceros
  end

  def grammar
    Importers::Bolton::Catalog::Species::Grammar
  end

  def self.convert_history_to_taxts history, genus_name = nil, species_name = nil
    Progress.method
    (history || []).inject([]) do |taxts, item|
      taxts.concat convert_item_to_taxts(item, genus_name, species_name)
    end
  end

  def self.convert_item_to_taxts item, genus_name, species_name
    texts = Importers::Bolton::Catalog::Grammar.parse(item[:matched_text], root: :texts).value[:texts]
    if item[:matched_text] =~ /^\s*Current subspecies:/
      change_key texts, :species_group_epithet, :subspecies_epithet
    end
    texts.inject([]) do |taxts, text|
      taxts << Importers::Bolton::Catalog::TextToTaxt.convert(text[:text], genus_name, species_name)
    end
  end

  def fix_nomen_nudum_in_brackets
    Taxon.where(status: 'nomen nudum').all.each do |taxon|
      for history in taxon.history_items
        if history.taxt =~ /\[.*Nomen nudum.*\]/
          taxon.update_attribute :status, 'valid'
          next
        end
      end
    end
  end

  def self.change_key object, from, to
    if object.kind_of? Hash
      if object.key? from
        object[to] = object[from]
        object.delete from
      end
      for subobject in object.values
        change_key subobject, from, to
      end
    elsif object.kind_of? Array
      for subobject in object
        change_key subobject, from, to
      end
    end
  end

  def show_results
    Progress.puts
    Progress.show_results
    unignored_lines_count = Progress.processed_count - @ignored_count
    Progress.puts "#{unignored_lines_count} unignored lines"
    Progress.puts "#{@ignored_count} see-unders (ignored)"
    Progress.puts "#{@genus_headers_count} genus headers"
    Progress.puts "#{@species_count} species"
    Progress.puts "#{@genera_not_found_count} genera not found" unless @genera_not_found_count.zero?
    Progress.puts "#{@duplicate_genera_that_need_resolving_count} duplicate genera that need resolving" unless @duplicate_genera_that_need_resolving_count.zero?
    Progress.puts "#{@error_count} could not understand" unless @error_count.zero?
    Progress.puts "#{Update.count} updates"
    Progress.puts
  end

  def get_file_names _
    super Dir.glob("#{$BOLTON_DATA_DIRECTORY}/NGC-SPECIES *.htm")
    #['PHI-PO'].map {|e| "#{$BOLTON_DATA_DIRECTORY}/NGC-SPECIES #{e}.htm"}
  end

end
