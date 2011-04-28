#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

Citrus.load File.dirname(__FILE__) + '/reference_grammar'

class Bolton::Bibliography::Bibliography
  def initialize show_progress = false
    Progress.init show_progress
    @success_count = 0
  end

  def import_files filenames
    filenames.each do |filename|
      @filename = filename
      Progress.puts "Importing #{@filename}..."
      import_html File.read @filename
      show_results
      Progress.puts
    end
    show_results
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
      original = pre_parse!(string).dup
      return unless reference? string
      attributes = Bolton::Bibliography::ReferenceGrammar.parse(string, :consume => false).value
      post_parse attributes
      attributes.merge! :original => original
      reference = Bolton::Reference.create! attributes
    rescue Citrus::ParseError => e
      puts e
    end
    tally_and_show_progress reference
  end

  def reference? string
    string.match(/^Note: /).blank?
  end

  def pre_parse! string
    string.replace CGI.unescapeHTML(string)
    string.gsub! /&nbsp;/, ' '
    string.gsub! /\n/, ' '
    remove_attributes! string
    string.strip!
    string
  end

  def post_parse attributes
    attributes[:journal] = remove_italic(attributes[:journal]) if attributes[:journal]
    attributes[:series_volume_issue] = remove_bold attributes[:series_volume_issue] if attributes[:series_volume_issue]
    attributes[:place].strip! if attributes[:place]
    attributes[:title] = remove_period remove_italic remove_span remove_bold attributes[:title]
    attributes[:note] = remove_italic attributes[:note] if attributes[:note]
  end

  def remove_attributes! string
    string.gsub! /<(\w+).*?>/, '<\1>'
  end

  def remove_span string
    remove_tag 'span', string
  end

  def remove_italic string
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

  def tally_and_show_progress reference
    @success_count += 1 if reference
    Progress.tally_and_show_progress 100
  end

  def show_results
    Progress.show_count(@success_count, Progress.processed_count, 'successful')
    Progress.show_count(Bolton::Reference.all(:conditions => 'reference_type != "UnknownReference"').count, Progress.processed_count, 'not unknown')
    Progress.show_results
  end

end
