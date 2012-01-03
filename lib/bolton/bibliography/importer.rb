# coding: UTF-8
#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

class Bolton::Bibliography::Importer
  def initialize show_progress = false
    Progress.init show_progress, nil, self.class.name
  end

  def import_files filenames
    Bolton::Reference.update_all(:import_result => nil)
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
    string = pre_parse! string
    original = string.dup
    return unless reference? string
    attributes = Bolton::Bibliography::Grammar.parse(string, :consume => false).value
    post_parse attributes
    attributes.merge! :original => original
    Bolton::Reference.import attributes
  rescue Citrus::ParseError => e
  end

  def reference? string
    string.match(/^Note: /).blank?
  end

  def pre_parse! string
    string.gsub! / /, ' ' # 0x00A0, which is what we get from Nokogiri from &nbsp;
    string.gsub! /&nbsp;/, ' '
    string.replace CGI.unescapeHTML(string)
    string.gsub! /\n/, ' '
    remove_attributes! string
    string.strip!
    string = remove_span string
    string.strip!
    string.gsub /<p><\/p>/, ''
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
    "#{reference.to_s} #{reference.id}"
  end

  def show_results
    last_last_name = ''
    Bolton::Reference.where("(import_result = 'added' AND year != 2011) OR import_result IS NULL").all.sort_by do |a|
      a.authors + a.citation_year + a.title
    end.each do |reference|
      this_last_name = reference.authors.split(/,|\s/).first
      if this_last_name != last_last_name
        Progress.puts
        last_last_name = this_last_name
      end
      Progress.puts "#{reference.import_result.nil? ? "Unseen:" : "Added: "} #{display_reference reference}"
    end
    Progress.puts
    Progress.puts "#{Bolton::Reference.count.to_s.rjust(4)} total"
    Progress.puts "#{Bolton::Reference.where(:import_result => 'identical').count.to_s.rjust(4)} identical"

    added_count = Bolton::Reference.where(:import_result => 'added').count
    added_2011_count = Bolton::Reference.where(:import_result => 'added', :year => 2011).count
    Progress.puts "#{(added_count - added_2011_count).to_s.rjust(4)} added (not counting #{added_2011_count} published in 2011)"

    Progress.puts "#{Bolton::Reference.where(:import_result => 'updated_title').count.to_s.rjust(4)} updated title"
    Progress.puts "#{Bolton::Reference.where(:import_result => 'updated').count.to_s.rjust(4)} updated other"
    Progress.puts "#{Bolton::Reference.where(:import_result => 'updated_spans_removed').count.to_s.rjust(4)} updated (minor changes)"
    Progress.puts "#{Bolton::Reference.where(:import_result => nil).count.to_s.rjust(4)} not seen"
  end

end
