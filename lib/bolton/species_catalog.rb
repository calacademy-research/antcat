#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use
#  1) Open the file in Word
#  2) Save it as web page

#  To import these files, run
#    rake bolton:import:species

require 'progress'

class Progress
  def self.open_log name
    file = File.open name, 'w'
    file.sync = true
    @logger = Logger.new file
  end

  def self.info string
    @logger.info string
    puts string
  end

  def self.error string
    string = '*** ERROR: ' + string
    @logger.error string
    puts string
  end

  def self.show_and_log_results
    @logger.info Progress.results_string
    show_results
  end
end

class Bolton::SpeciesCatalog
  def initialize show_progress = false
    Progress.init show_progress
    Progress.open_log 'log/bolton_species_import.log'
    @success_count = @error_count = 0
  end

  def clear
    Species.delete_all
  end

  def import_files filenames
    @genus = nil
    #filenames.each do |filename|
    [filenames.first].each do |filename|
      @filename = filename
      Progress.puts "Importing #{@filename}..."
      import_html File.read @filename
      Progress.show_results
      Progress.puts
    end
    Progress.show_and_log_results
    Progress.show_count @error_count, Progress.processed_count, 'parse failures'
  end

  def import_html html
    initialize_scan html
    parse_header
    while @line
      parse_see_under || parse_genus_section || parse_failed
    end
  end

  def parse_header
    return unless @line && parse(@line)[:type] == :header
    Progress.info ">>>> HEADER"
    get_next_line
    true
  end

  def parse_see_under
    return unless @line && parse(@line)[:type] == :see_under
    Progress.info ">>>> SEE UNDER"
    get_next_line
    true
  end

  def parse_genus_section
    return unless @line && parse(@line)[:type] == :genus
    Progress.info ">>>> GENUS SECTION"
    get_next_line
    while parse_species; end
    true
  end

  def parse_species
    return unless @line && parse(@line)[:type] == :species
    Progress.info ">>>> SPECIES"
    get_next_line
    true
  end

  def parse string
    string.strip!
    v = Bolton::SpeciesCatalogGrammar.parse(string).value
    Progress.info v
    v
  rescue Citrus::ParseError => e
    Progress.error 'Parse error'
    Progress.error e
    p e
    nil
  end

  def import_species record
    unless @genus
      Progress.error 'No genus'
      Progress.error @filename
      Progress.error record
      return
    end
    genus = Genus.find_or_create_by_name @genus
    Species.create! :name => record[:species], :parent => genus
    Progress.tally_and_show_progress 100
  end

  private
  def initialize_scan html
    doc = Nokogiri::HTML html
    @lines = doc.css('p')
    @index = 0
    get_next_line
  end

  def parse_failed
    @error_count += 1
    Progress.error "Couldn't parse: [#{@line}]"
    get_next_line
  end

  def get_next_line
    while get_next_line_including_blanks && parse(@line)[:type] == :blank
      Progress.info '>>> BLANK'
    end
  end

  def get_next_line_including_blanks
    if @index >= @lines.size
      @line = nil
      return
    end
    @line = @lines[@index].inner_html.gsub /\n/, ' '
    @index += 1
    Progress.info "\n[" + @line + "]"
    @line
  end
end
