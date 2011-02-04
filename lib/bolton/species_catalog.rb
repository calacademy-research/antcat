#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use
#  1) Open the file in Word
#  2) Save it as web page

#  To import these files, run
#    rake bolton:import:species
#
#  Note: NGC-Spcam2.docx is actually the continuation of NGC-Spcam1.docx
#  and doesn't have the Camponotus genus header. The code makes a special
#  case for this file, so make sure its name when importing is
#  NGC-Spcam2.htm.
# 
#  Manual edits:
#   In NGC-Spg-las.htm, removed extra paragraph in Lasius murphyi
#   In NGC-Spcan-cr.htm, removed extra paragraph in Cephalotes texanus

class Bolton::SpeciesCatalog
  def initialize show_progress = false
    Progress.init show_progress
    Progress.open_log 'log/bolton_species_import.log'
    @success_count = @error_count = 0
  end

  def import_files filenames
    Species.delete_all
    @genus = nil
    filenames.each do |filename|
      @filename = filename
      Progress.puts "Importing #{@filename}..."
      @inserting_camponotus_genus_header = filename =~ /NGC-Spcam2/
      import_html File.read @filename
      Progress.show_results
      Progress.puts
    end
    Progress.show_results
    Progress.show_count @error_count, Progress.processed_count, 'parse failures'
  end

  def import_html html
    initialize_scan html
    parse_header
    while @line
      parse_see_under || parse_genus_section || parse_failed
    end
  end

  def parse string
    string.strip!
    parse_result = Bolton::SpeciesCatalogGrammar.parse(string).value
    Progress.info parse_result
    parse_result
  rescue Citrus::ParseError => e
    Progress.error 'Parse error'
    Progress.error e
    p e
    nil
  end

  private
  def initialize_scan html
    doc = Nokogiri::HTML html
    @lines = doc.css('p')
    @index = 0
    @parse_result = {:type => :eof}
    parse_next_line
  end

  def parse_header
    return unless @type == :header
    parse_next_line
    true
  end

  def parse_see_under
    return unless @type == :see_under
    parse_next_line
    true
  end

  def parse_genus_section
    return unless @type == :genus
    parse_next_line
    while parse_species; end
    true
  end

  def parse_species
    return unless @type == :species || @type == :subspecies
    parse_next_line
    true
  end

  def parse_failed
    Progress.error "#{@line}\n"
    @error_count += 1
    parse_next_line
  end

  def parse_next_line
    while get_next_line_including_blanks
      @parse_result = parse @line
      next unless @parse_result
      @type = @parse_result[:type]
      if @type == :not_understood
        parse_failed
      elsif not [:blank, :note].include? @type
        return @type
      end
    end
  end

  def get_next_line_including_blanks
    if @index >= @lines.size
      @line = @type = @parse_result = nil
      return
    end
    if @inserting_camponotus_genus_header
      @line = '<b><i><span color:red>CAMPONOTUS</span></i></b>'
      @inserting_camponotus_genus_header = false
    else
      @line = massage @lines[@index].inner_html
      @index += 1
    end
    Progress.info "\n[" + @line + "]"
    Progress.tally
    @line
  end

  def massage line
    CGI.unescape line.gsub /\n/, ' '
  end
end
