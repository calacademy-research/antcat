# coding: UTF-8
class Bolton::Catalog::Species::DeepSpeciesImporter < Bolton::Catalog::Importer

  def initialize options = {}
    Progress.open_log self.class.name
    @options = options.reverse_merge show_progress: false
    @continue_after_parse_error = true
    @return_blank_lines = true
    super @options[:show_progress]
  end

  def import
    @error_count = @non_species_count = @success_count = 0

    while @line
      case @type
      when :not_understood
        @error_count += 1
      when :catalog_header, :genus_see_under, :genus_header, :species_see_under, :blank_line, :note
        @non_species_count += 1
      when :species_record, :subspecies_record
        @success_count += 1
      else
        raise "Unexpected type: #{@type}"
      end

      if @error_count + @non_species_count + @success_count != Progress.processed_count
        pp @parse_result
        raise "Totals don't match"
      end

      parse_next_line
    end

    Progress.show_results
    species_lines = Progress.processed_count - @non_species_count
    Progress.puts "#{species_lines} total species lines"
    Progress.show_count @success_count, species_lines, "species lines parsed"
    Progress.show_count @error_count, Progress.processed_count, "errors"
  end

  def grammar
    Bolton::Catalog::Species::DeepSpeciesGrammar
  end

end
