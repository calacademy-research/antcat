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
    @genus_count =
      @genus_not_found_count =
      @duplicate_genera_that_need_resolving_count =
    @species_count =
    @error_count =
    @ignored_count =
    @species_without_protonym_count =
    0

    while @line
      case @type

      when :not_understood
        @error_count += 1

      when :catalog_header, :genus_see_under, :species_see_under, :note
        @ignored_count += 1

      when :genus_header
        @genus_count += 1
        @genus = nil
        matching_genus_names = Genus.with_names.where "name = '#{@parse_result[:name]}'"
        if matching_genus_names.empty?
          Progress.error "Genus '#{@parse_result[:name]}' did not exist"
          @genus_not_found_count += 1
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
                                      history: convert_taxonomic_history_to_taxts(@parse_result[:history])
            Progress.log "Imported #{species.inspect}"
            @species_count += 1
          rescue Species::NoProtonymError
            Progress.error "Species without protonym: #{@line}"
            @species_without_protonym_count += 1
          end

        else Progress.error "Species with no active genus: #{@line}"
        end

      else raise "Unexpected type: #{@type}"
      end

      parse_next_line
    end

    finish_importing

    Progress.show_results
    unignored_lines_count = Progress.processed_count - @ignored_count
    Progress.puts "#{unignored_lines_count} lines"
    Progress.puts "#{@genus_count} genera"
    Progress.puts "#{@species_count} species"
    Progress.puts "#{@genus_not_found_count} genera not found"
    Progress.puts "#{@duplicate_genera_that_need_resolving_count} duplicate genera that need resolving"
    Progress.puts "#{@species_without_protonym_count} species without protonyms"
    Progress.puts "#{@error_count} could not understand"
  end

  def finish_importing
    Progress.print 'Fixing up names...'
    SpeciesGroupForwardRef.fixup
    Progress.puts
  end

  def grammar
    Importers::Bolton::Catalog::Species::Grammar
  end

  def convert_taxonomic_history_to_taxts history
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

end
