# coding: UTF-8
#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

class Bolton::Bibliography::Importer
  def initialize show_progress = false
    Progress.init show_progress, nil, self.class.name
    Bolton::Reference.update_all :import_result => nil
  end

  def import_files filenames
    filenames.each do |filename|
      @filename = filename
      Progress.puts "Importing #{@filename}..."
      import_html File.read @filename
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
      attributes = Bolton::Bibliography::Grammar.parse(string, :consume => false).value
      post_parse attributes
      attributes.merge! :original => original
      reference = Bolton::Reference.import attributes
    rescue Citrus::ParseError => e
    end
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

  def display_reference reference
    {:authors => reference.authors, :citation_year => reference.citation_year, :title => reference.title}
  end

  def show_results
    last_last_name = ''
    Bolton::Reference.where("import_result = 'added' OR import_result IS NULL").all.sort_by do |a|
      a.authors + a.citation_year + a.title
    end.each do |reference|
      this_last_name = reference.authors.split(/,|\s/).first
      if this_last_name != last_last_name
        Progress.log ''
        last_last_name = this_last_name
      end
      Progress.log "#{reference.import_result.nil? ? "Unseen:" : "Added: "} #{display_reference reference}"
    end
    Progress.puts
    Progress.puts "#{Bolton::Reference.count.to_s.rjust(4)} total"
    Progress.puts "#{Bolton::Reference.where(:import_result => 'identical').count.to_s.rjust(4)} identical"
    Progress.puts "#{Bolton::Reference.where(:import_result => 'added').count.to_s.rjust(4)} added"
    Progress.puts "#{Bolton::Reference.where(:import_result => 'updated').count.to_s.rjust(4)} updated"
    Progress.puts "#{Bolton::Reference.where(:import_result => nil).count.to_s.rjust(4)} not seen"
  end

end
