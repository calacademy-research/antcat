#  The Bolton genus catalog files are NGC-GEN.A-L.docx and NGC-GEN.M-Z.docx.

#  To convert a genus catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:genera
#  This generates log/bolton_genus_import.log

class Bolton::GenusCatalog
  def initialize show_progress = false
    Progress.init show_progress
    Progress.open_log 'log/bolton_genus_import.log'
    @success_count = @error_count = 0
  end

  def import_files filenames
    Taxon.delete_all
    filenames.each do |filename|
      Progress.puts "Importing #{filename}..."
      import_html File.read filename
    end
    show_results
  end

  def import_html html
    initialize_scan html
    parse_header || parse_failed
    while @line
      parse_genus_section || parse_failed
    end
  end

  def parse string
    string.strip!
    parse_result = Bolton::GenusCatalogGrammar.parse(string).value
    Progress.info parse_result
    parse_result
  rescue Citrus::ParseError => e
    Progress.error 'Parse error'
    Progress.error e
    p e
    nil
  end

  def parse_genus_section
    return unless [:subgenus, :genus].include? @type

    if @type == :genus
      save_genus @parse_result.merge :taxonomic_history => @line
    end

    parse_next_line
    while parse_genus_section_line; end
    while parse_blank_line; end
    true
  end

  def parse_genus_section_line
    return unless @type == :non_blank_line
    parse_next_line true
    true
  end

  def parse_blank_line
    return unless @type == :blank_line
    parse_next_line true
    true
  end

  def save_genus record
    subfamily_name = record[:subfamily]
    tribe_name = record[:tribe]
    synonym_of_name = record[:synonym_of]
    homonym_of_name = record[:homonym_of]

    subfamily = subfamily_name && Subfamily.find_or_create_by_name(subfamily_name, :status => 'valid')
    raise if subfamily && !subfamily.valid?

    tribe = tribe_name && Tribe.find_or_create_by_name(tribe_name, :subfamily => subfamily, :status => 'valid')
    raise if tribe && !tribe.valid?

    synonym_of = synonym_of_name && Genus.find_or_create_by_name(synonym_of_name, :status => 'valid')
    raise if synonym_of && !synonym_of.valid?

    homonym_of = homonym_of_name && Genus.find_or_create_by_name(homonym_of_name, :status => 'valid')
    raise if homonym_of && !homonym_of.valid?

    genus = Genus.find_or_create_by_name record[:name],
      :fossil => record[:fossil], :status => record[:status].to_s,
      :subfamily => subfamily, :tribe => tribe, 
      :synonym_of => synonym_of, :homonym_of => homonym_of,
      :taxonomic_history => record[:taxonomic_history]
    raise unless genus.valid?
  end

  def show_results
    Progress.show_results
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

  def parse_failed
    Progress.error "#{@line}\n"
    @error_count += 1
    parse_next_line
  end

  def parse_next_line return_blank_lines = false
    while get_next_line_including_blanks
      lll{'@line'}
      @parse_result = parse @line
      lll{'@parse_result'}
      next unless @parse_result
      @type = @parse_result[:type]
      if @type == :not_understood
        parse_failed
      elsif @type == :blank
        return @type if return_blank_lines
      elsif not @type != :note
        return @type
      end
    end
  end

  def get_next_line_including_blanks
    if @index >= @lines.size
      @line = @type = @parse_result = nil
      return
    end
    @line = massage @lines[@index].inner_html
    @index += 1
    Progress.info "\n[" + @line + "]"
    Progress.tally
    @line
  end

  def massage line
    CGI.unescape line.gsub /\n/, ' '
  end
end
