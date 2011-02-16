#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:species
#  This generates log/bolton_species_import.log
#
#  Manual edits:
#   In NGC-Spg-las.htm, removed extra paragraph in Lasius murphyi
#   In NGC-Spcan-cr.htm, removed extra paragraph in Cephalotes texanus

class Bolton::SpeciesCatalog
  def initialize show_progress = false
    Progress.init show_progress
    Progress.open_log 'log/bolton_species_import.log'
    @error_count = 0
  end

  def import_files filenames
      initialize_parse filenames.sort_by {|filename| File.basename(filename, File.extname(filename))}
      import
  end

  def import_html html
    initialize_parse_html html
    import
  end

  def parse string
    begin
      string.strip!
      parse_result = Bolton::SpeciesCatalogGrammar.parse(string).value
      Progress.info "parsed as: #{parse_result.inspect}"
    rescue Citrus::ParseError => e
      parse_result = {:type => :not_understood}
      Progress.error 'citrus parse error:'
      Progress.error e
    end
    parse_result
  end

  private
  def import
    Species.delete_all
    @genus = nil
    parse_header || parse_failed if @line
    parse_see_under || parse_genus_section || parse_failed while @line
    Progress.show_results
    Progress.show_count @error_count, Progress.processed_count, 'parse failures'
  end

  def parse_header
    return unless @type == :header
    parse_next_line
  end

  def parse_see_under
    return unless @type == :see_under
    parse_next_line
  end

  def parse_genus_section
    return unless @type == :genus

    @genus = Genus.find_or_create_by_name :name => @parse_result[:name], :fossil => @parse_result[:fossil], :status => @parse_result[:status].to_s
    raise unless @genus.valid?

    parse_next_line
    parse_species_lines
  end

  def parse_species_lines
    while @line && (parse_note || parse_species); end
    true
  end

  def parse_species
    return unless @type == :species || @type == :subspecies

    if @type == :species
      Species.create! :name => @parse_result[:name], :fossil => @parse_result[:fossil], :status => @parse_result[:status].to_s, :genus => @genus
    end

    parse_next_line
    true
  end

  def parse_note
    return unless @type == :note
    parse_next_line
  end

  def parse_failed
    Progress.error "parse failed on: '#{@line}'"
    @error_count += 1
    parse_next_line
  end

  def initialize_parse filenames
    @filenames = filenames
    @filename_index = 0
    read_file
    parse_next_line
  end

  def initialize_parse_html html
    @filenames = []
    @filename_index = 0
    read_string html
    parse_next_line
  end

  def read_file
    return unless @filename_index < @filenames.size
    html = File.read @filenames[@filename_index]
    Progress.show_progress if @filename_index > 0
    Progress.puts "Parsing #{@filenames[@filename_index]}...", true
    @filename_index += 1
    read_string html
  end

  def read_string html
    doc = Nokogiri::HTML html
    @paragraphs = doc.css('p')
    @paragraph_index = 0
  end

  def parse_next_line
    begin
      get_next_line
      return unless @line
      @parse_result = parse @line
      @type = 
      case @parse_result
      when Symbol then @parse_result
      else @parse_result[:type]
      end
    end while @type == :blank_line
    @type
  end

  def get_next_line
    while @paragraph_index >= @paragraphs.size
      unless read_file
        @line = @type = @parse_result = nil
        return
      end
    end
    @line = massage @paragraphs[@paragraph_index].inner_html
    @paragraph_index += 1
    Progress.info "input line: '#{@line}'"
    Progress.tally
    @line
  end

  def massage line
    CGI.unescape(line.gsub /\n/, ' ').strip
  end
end
