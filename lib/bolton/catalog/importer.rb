class Bolton::Catalog::Importer

  def initialize show_progress = false
    Progress.init show_progress
    Progress.open_log Rails.root.join 'log/' + self.class.name.underscore.gsub(/\//, '_') + '.log'
    Progress.info "==============================="
    @error_count = 0
  end

  def import_files filenames
    initialize_parse get_filenames filenames
    import
  end

  def import_html html
    initialize_parse_html html
    import
  end

  def parse string
    begin
      string = string.gsub(/\n/, ' ').strip
      parse_result = grammar.parse(string).value
      Progress.info "parsed as: #{parse_result.inspect}"
      raise if parse_result.is_a?(Hash) && parse_result[:type] == :not_understood && !Rails.env.test?
    rescue Citrus::ParseError => e
      parse_result = {:type => :not_understood}
      Progress.error 'citrus parse error:'
      Progress.error e
      raise unless Rails.env.test?
      $stderr.puts e
    end
    parse_result
  end

  def clean_taxonomic_history taxonomic_history
    taxonomic_history = taxonomic_history.dup
    ['i', 'b', 'p'].each do |tag|
      taxonomic_history.gsub! /<#{tag}.*?>/, "<#{tag}>"
    end
    taxonomic_history.gsub! /<span.*?>/, ''
    taxonomic_history.gsub! /<\/span>/, ''
    taxonomic_history
  end

  private
  def get_filenames filenames
    filenames.sort_by {|filename| File.basename(filename, File.extname(filename))}
  end

  def import
    Progress.show_results
    Progress.show_count @error_count, Progress.processed_count, 'parse failures'
  end

  def grammar
    raise NotImplementedError
  end

  def parse_header
    return unless @type == :header
    parse_next_line
  end

  def parse_failed
    Progress.error "parse failed on: '#{@line}'"
    raise unless Rails.env.test?
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
    html = save_quot_character_entity html
    doc = Nokogiri::HTML html, nil, 'UTF-8'
    @paragraphs = doc.css('div/p')
    @paragraph_index = 0
  end

  def save_quot_character_entity html
    html.gsub /&quot;/, 'SAVED_QUOT_CHARACTER_ENTITY'
  end

  def restore_quot_character_entity html
    html.gsub /SAVED_QUOT_CHARACTER_ENTITY/, '&quot;'
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
    @line = preprocess @paragraphs[@paragraph_index].inner_html(:encoding => 'UTF-8')
    @paragraph = preprocess @paragraphs[@paragraph_index].to_html(:encoding => 'UTF-8')
    @paragraph_index += 1
    Progress.info "input line: '#{@line}'"
    Progress.tally
    @line
  end

  def preprocess line
    line.gsub! %r{<span style="mso-spacerun: yes">.*?</span>}, ''
    restore_quot_character_entity line.gsub(/\n/, ' ').strip
  end

  def expect type
    raise "Expecting #{type}" unless @type == type
  end

  def skip type
    parsed_text = ''
    while @type == type
      parsed_text << @paragraph
      parse_next_line
    end
    parsed_text
  end
end
