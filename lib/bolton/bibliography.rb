#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

class Bolton::Bibliography
  def initialize filename, show_progress = false
    Progress.init show_progress
    @filename = filename.to_s
    @success_count = 0
  end

  def import_file
    Progress.puts "Importing #{@filename}..."
    import_html File.read(@filename)
    Progress.puts
  end

  def import_html html
    doc = Nokogiri::HTML html
    ps = doc.css('p')
    ps.each do |p|
      line = p.inner_html
      next if header? line
      next if blank? line
      reference = import_reference line
    end
    show_results
  end

  def header? line
    line =~ /CATALOGUE REFERENCES/
  end

  def blank? line
    line.length < 20
  end

  def import_reference string
    reference = nil
    begin
      pre_parse string
      return unless reference? string
      attributes = Bolton::ReferenceGrammar.parse(string).value
      post_parse attributes
      reference = Bolton::Reference.create! attributes
    rescue Citrus::ParseError => e
      puts e
    end
    record_and_show_progress reference
  end

  def reference? string
    string.match(/^Note: /).blank?
  end

  def pre_parse string
    string.replace CGI.unescapeHTML(string)
    string.gsub! /&nbsp;/, ' '
    string.gsub! /\n/, ' '
  end

  def post_parse attributes
    attributes[:title] = remove_period remove_italics attributes[:title]
    attributes[:journal] = remove_italics(attributes[:journal]) if attributes[:journal]
    attributes[:series_volume_issue] = remove_bold attributes[:series_volume_issue] if attributes[:series_volume_issue]
    attributes[:place].strip! if attributes[:place]
    attributes[:title] = remove_italics remove_span remove_bold attributes[:title]
  end

  def remove_span string
    remove_tag 'span', string
  end

  def remove_italics string
    remove_tag 'i', string
  end

  def remove_bold string
    remove_tag 'b', string
  end

  def remove_tag tag, string
    string.gsub /<#{tag}.*?>(.*?)<\/#{tag}>/, '\1'
  end

  def remove_period string
    string = string.strip
    string = string[0..-2] if string[-1..-1] == '.'
    string
  end

  def record_and_show_progress reference
    Progress.tally
    @success_count += 1 if reference
    return unless Progress.processed_count % 100 == 0
    show_progress
  end

  def show_progress
    Progress.puts "#{@success_count}/#{Progress.processed_count} parsed (#{Progress.percent @success_count}) in #{Progress.elapsed} (#{Progress.rate})"
  end

  def show_results
    Progress.puts
    show_progress
  end

end
