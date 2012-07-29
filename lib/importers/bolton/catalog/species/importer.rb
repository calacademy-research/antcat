# coding: UTF-8
class Importers::Bolton::Catalog::Species::Importer < Importers::Bolton::Catalog::Importer

  def initialize options = {}
    Species.delete_all
    Subspecies.delete_all
    SpeciesGroupForwardRef.delete_all

    @options = options.reverse_merge show_progress: false
    @continue_after_parse_error = true
    @return_blank_lines = false
    super @options[:show_progress]
    Progress.total_count = 25870
  end

  def import
    @genus_headers_count =
      @genera_not_found_count =
      @duplicate_genera_that_need_resolving_count =
    @species_count =
    @error_count =
    @ignored_count =
    0

    while @line
      case @type

      when :not_understood
        @error_count += 1

      when :note
        @genus.update_attribute :genus_species_header_note, convert_line_to_taxt(@parse_result[:text]) if @genus

      when :catalog_header, :genus_see_under, :species_see_under
        @ignored_count += 1

      when :genus_header
        @genus_headers_count += 1
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

      when :species_record
        if @genus
          begin
            species = ::Species.import species_epithet: @parse_result[:species_group_epithet],
                                      fossil: @parse_result[:fossil] || false,
                                      status: @parse_result[:status] || 'valid',
                                      genus: @genus,
                                      protonym: @parse_result[:protonym],
                                      raw_history: @parse_result[:history],
                                      history: self.class.convert_taxonomic_history_to_taxts(@parse_result[:history])
            Progress.info "Imported #{species.inspect}"
            @species_count += 1
          end

        elsif @parse_result[:species_group_epithet] != 'heerii'
          Progress.error "Species with no active genus: #{@line}"
        end

      else raise "Unexpected type: #{@type}"
      end

      parse_next_line
    end

    do_manual_fixups

    finish_importing

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
    Progress.puts
  end

  def finish_importing
    Progress.print 'Fixing up names...'
    SpeciesGroupForwardRef.fixup
    set_status_manually 'Camponotus abdominalis', 'homonym'
    set_status_manually 'Camponotus (Camponotus) herculeanus var. rubens', 'synonym'
    set_synonym 'Camponotus (Camponotus) herculeanus var. rubens', 'Camponotus novaeboracensis'
    Progress.puts
  end

  def set_synonym junior, senior
    junior = Taxon.find_by_name junior
    senior = Taxon.find_by_name senior
    Synonym.create! junior_synonym: junior, senior_synonym: senior
    junior.update_attribute :status, 'synonym'
  rescue
  end

  def do_manual_fixups
    set_status_manually 'Temnothorax foreli', 'homonym', 1
    set_status_manually 'Temnothorax manni', 'homonym', [1, 2]
    set_status_manually 'Tetramorium pauper', 'homonym', 1
    set_status_manually 'Camponotus abdominalis', 'valid'
    set_status_manually 'Camponotus (Camponotus) herculeanus var. rubens', 'valid'
    set_status_manually 'Camponotus terebrans', 'valid'
    set_status_manually 'Ectatomma permagnum', 'valid'
    set_status_manually 'Attaichnus kuenzelii', 'ichnotaxon'
    set_status_manually 'Myrmeciites goliath', 'collective group name'
    set_status_manually 'Myrmeciites herculeanus', 'collective group name'
    set_status_manually 'Myrmeciites tabanifluviensis', 'collective group name'
    Species.import_myrmicium_heerii unless Rails.env.test?
  end

  def grammar
    Importers::Bolton::Catalog::Species::Grammar
  end

  def self.convert_taxonomic_history_to_taxts history
    Progress.method
    (history || []).inject([]) do |items, item|
      for text in Importers::Bolton::Catalog::Grammar.parse(item[:matched_text], root: :texts).value[:texts]
        taxt = Importers::Bolton::Catalog::TextToTaxt.convert text[:text]
        if taxt.present?
          items << taxt
        else
          Progress.error "Blank taxonomic history item: #{@line}"
        end
      end
      items
    end
  end

  def get_file_names _
    super Dir.glob("#{$BOLTON_DATA_DIRECTORY}/NGC-Sp*.htm")
    #['cr', 'st-tet'].map {|e| "#{$BOLTON_DATA_DIRECTORY}/NGC-Sp#{e}.htm"}
  end

end
