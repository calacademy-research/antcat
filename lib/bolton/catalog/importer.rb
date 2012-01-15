# coding: UTF-8
require 'asterisk_dagger_formatting'
class Bolton::Catalog::Importer

  def initialize show_progress = false
    @show_parsing = true
    Progress.init show_progress, nil, self.class.name
    Progress.info "==============================="
    @error_count = 0
  end

  def import_files file_names
    file_names = get_file_names file_names
    raise "No files" unless file_names.present?
    initialize_parse file_names
    import
  end

  def import_html html
    initialize_parse_html html
    import
  end

  def parse string, rule = nil
    begin
      @line = normalize string
      return :blank_line unless @line.present? && @line != '.'
      parse_result = grammar.parse(@line, root: rule).value
      Progress.info @line if @show_parsing
      Progress.info "  parsed as:\n#{parse_result.pretty_inspect}" if @show_parsing
    rescue Citrus::ParseError => e
      return parse string if rule
      Progress.error e
      parse_result = {type: :not_understood}
    rescue Exception => e
      parse_result = {type: :not_understood}
      Progress.info "Exception: " + e.inspect
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
    taxonomic_history = taxonomic_history.convert_asterisks_to_daggers
    taxonomic_history
  end

  def get_file_names file_names
    file_names.sort_by {|file_name| File.basename(file_name, File.extname(file_name))}
  end

  def import
    Progress.show_results
  end

  def grammar
    raise NotImplementedError
  end

  def parse_header
    return unless @type == :header
    parse_next_line
  end

  def initialize_parse file_names
    @file_names = file_names
    @file_name_index = 0

    read_file
    parse_next_line
  end

  def initialize_parse_html html
    @file_names = []
    @file_name_index = 0
    read_string html
    parse_next_line
  end

  def read_file
    return unless @file_name_index < @file_names.size
    html = File.read @file_names[@file_name_index]
    Progress.show_progress if @file_name_index > 0
    Progress.puts "Parsing #{@file_names[@file_name_index]}..."
    @file_name_index += 1
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

  def parse_next_line rule = nil
    loop do
      @type = nil
      @line = get_next_line
      return unless @line
      @parse_result = parse @line, rule

      @type =
      case @parse_result
        when Symbol, String then @parse_result
        when Hash then @parse_result[:type] ? @parse_result[:type] : :text
      end
      break if @type != :blank_line || @return_blank_lines
    end
    @type
  end

  def get_next_line
    while @paragraph_index >= @paragraphs.size
      unless read_file
        @line = @type = @parse_result = nil
        return
      end
    end
    line = preprocess @paragraphs[@paragraph_index].inner_html(encoding: 'UTF-8')
    @paragraph = preprocess @paragraphs[@paragraph_index].to_html(encoding: 'UTF-8')
    @paragraph_index += 1
    Progress.tally
    line
  end

  def preprocess line
    line.replace CGI.unescapeHTML line
    line.gsub! %r{<span style="mso-spacerun: yes">.*?</span>}, ''
    restore_quot_character_entity line.gsub(/\n/, ' ').strip
  end

  def expect type, text = nil
    raise "Expecting #{type}; got #{@type}: '#{@line}'" unless @type == type
    raise "Expecting #{type}; '#{text}', got #{@line}" unless !text || @line == text
  end

  def consume type
    expect type
    parse_result = @parse_result
    parse_next_line
    parse_result
  end

  def get type
    parse_next_line
    expect type
  end

  def skip type
    parsed_text = ''
    while @type == type
      parsed_text << @paragraph
      parse_next_line
    end
    parsed_text
  end

  ###################################################################################################

  def normalize string
    fix_ending_punctuation(
    fix_et_al(
    squish_spaces(
    fix_no_space_after_semicolon(
    fix_double_periods(
    fix_space_before_period(
    normalize_italics(
    remove_bold(
    remove_spans(
    remove_inner_paragraphs(
    remove_mismatched_brackets(
    replace_character_entities(
    fix_utf_characters(
      string)))))))))))))
  end

  def fix_no_space_after_semicolon string
    string.gsub /;(\S)/, '; \1'
  end

  def fix_et_al string
    et_al = '<i>et al.</i>'
    string.gsub!(/<i>et al<\/i>\./, et_al)
    string.gsub!(/([^>])et al\./, '\1' + et_al)

    string.gsub!(/([^,]) <i>et/, '\1, <i>et')
    string
  end

  def fix_ending_punctuation string
    string.gsub /[;,]$/, '.'
  end

  def fix_space_before_period string
    string.gsub /\s+\./, '.'
  end

  def fix_double_periods string
    string.gsub /\.\./, '.' 
  end

  def fix_utf_characters string
    string = string.gsub /’/, "'" 
    string = string.gsub /”/, '"'
    string = string.gsub /“/, '"'
    string = string.gsub /–/, '-'
    string = string.gsub / /, ' '
  end

  def replace_character_entities string
    string = CGI.unescapeHTML string
    string = string.gsub /&nbsp;/, ' '
  end

  ###################################################################################################

  def normalize_italics string
    move_close_italic_tag_in_between_parens(
    wrap_abbreviated_genus_and_parenthesized_subgenus_in_italics(
    italicize_comma_separated_items_separately(
    fix_italicized_commas(
    fix_italicized_colons(
    fix_italicized_parentheses(
    italicize_first_word_separately_and_add_period(
    unitalicize_genus_header(
    move_end_italic_tag_to_end_of_word_or_prior_tag(
    move_start_italic_tag_to_front_of_word(
    italicize_nomen_nudum_separately(
    remove_space_before_first_word(
    remove_empty_italics(
    unitalicize_periods(
    fix_incertae_sedis(
    remove_attributes_from_italic_tag(
      string))))))))))))))))
  end

  def move_close_italic_tag_in_between_parens string
    string.gsub %r{\)\)</i>}, ')</i>)'
  end

  def fix_incertae_sedis string
    string = string.gsub %/<i>) incertae/, ') <i>incertae'
    string = string.gsub %/<i> incertae/, ' <i>incertae'
    string = string.gsub %/<i>incertae sedis <\/i>/, '<i>incertae sedis</i> '
  end

  def unitalicize_periods string
    string.gsub %{<i>\.</i>}, '.'
  end

  def remove_space_before_first_word string
    string.gsub %r{^<i>\s+}, '<i>'
  end

  def remove_empty_italics string
    string.gsub %r{<i>\s*</i>}, ''
  end

  def wrap_abbreviated_genus_and_parenthesized_subgenus_in_italics string
    string.gsub %r{<i>([[:upper:]])</i>\. \(<i>([[:upper:]][[:lower:]]+)</i>\)}, '<i>\1. (\2)</i>'
  end

  def italicize_comma_separated_items_separately string
    string.gsub %r{<i>([^<]+,[^<]+)</i>} do |match|
      match.split(', ').map do |item|
        item = item.gsub(/(\*?)(.+)/, '\1<i>\2') unless item =~ /^<i>/
        item = item + '</i>' unless item =~ /<\/i>$/
        item
      end.join ', '
    end
  end

  def fix_italicized_parentheses string
    string.gsub %r{(\([\w]+)</i>\)}, '\1)</i>'
  end

  def fix_italicized_commas string
    string.gsub %r{,</i>}, '</i>,'
  end

  def fix_italicized_colons string
    string.gsub %r{:</i>}, '</i>:'
  end

  def unitalicize_genus_header string
    string.gsub /^<i>Genus /, 'Genus <i>'
  end

  def italicize_first_word_separately_and_add_period string
    # replace ". " with "</i>. <i>" if there is not already an </i> before the period
    # if fossil, replace ". *" with "</i>. *<i>"
    part_before_first_period_or_space = string.match(/^[^< .]*<i>[^. ]+/).to_s
    return string if part_before_first_period_or_space.empty? || part_before_first_period_or_space.index('</i>')
    string.gsub %r{(#{Regexp.escape part_before_first_period_or_space})(\.)? (\*?)}, '\1</i>\2 \3<i>'
  end

  def move_start_italic_tag_to_front_of_word string
    string.gsub /<i>([^<\w]+)/, '\1<i>'
  end

  def move_end_italic_tag_to_end_of_word_or_prior_tag string
    string.gsub %r{([\s.]+)</i>}, '</i>\1'
  end

  def remove_attributes_from_italic_tag string
    string.gsub /<i\b.*?>/, "<i>"
  end

  def remove_bold string
    string.gsub %r{<b\b.*?>(.*?)</b>}, '\1'
  end

  def squish_spaces string
    string.gsub(/(\n|\s|\xC2\xA0)+/, ' ').strip
  end

  def remove_spans string
    while string =~ /<span/ do
      string = string.gsub %r{<span[^>]*>(.*?)</span>}, '\1'
    end
    string
  end

  def remove_inner_paragraphs string
    string.gsub %r{<(o:)?p>.*?</(o:)?p>}, ''
  end

  def italicize_nomen_nudum_separately string
    string.gsub %r{omen nudum([\s.]+)}, 'omen nudum</i>\1<i>'
  end

  def remove_mismatched_brackets string
    remove_mismatched string, '(', ')'
    remove_mismatched string, '[', ']'
  end

  def remove_mismatched string, open, close
    open_bracket_positions = []
    unopened_bracket_positions = []

    string.length.times do |position|
      char = string[position,1]
      if char == open
        open_bracket_positions.push position
      elsif char == close
        if open_bracket_positions.present?
          open_bracket_positions.pop
        else
          unopened_bracket_positions.push position
        end
      end
    end

    for position in open_bracket_positions.concat(unopened_bracket_positions).sort.reverse
      string[position,1] = ''
    end

    string
  end

end
