#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use
#  1) Open the file in Word
#  2) Save it as web page

#  To import these files, run
#    rake import_species

class Bolton::SpeciesCatalog
  def initialize show_progress = false
    Progress.init show_progress
    @success_count = 0
  end

  def clear
    Species.delete_all
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
      species = import_species line
    end
  end

  def header? line
    line =~ /CATALOGUE REFERENCES/
  end

  def blank? line
    line.length < 20
  end

  def import_species string
    species = nil
    begin
      original = pre_parse!(string).dup
      return unless species? string
      attributes = Bolton::SpeciesGrammar.parse(string).value
      post_parse attributes
      species = Species.create! attributes.merge :original => original
    rescue Citrus::ParseError => e
      puts e
    end
    tally_and_show_progress species
  end

  def species? string
    #string.match(/^Note: /).blank?
  end

  def pre_parse! string
    #string.replace CGI.unescapeHTML(string)
    #string.gsub! /&nbsp;/, ' '
    #string.gsub! /\n/, ' '
    #remove_attributes! string
    #string.strip!
    #string
  end

  def post_parse attributes
    #attributes[:journal] = remove_italics(attributes[:journal]) if attributes[:journal]
    #attributes[:series_volume_issue] = remove_bold attributes[:series_volume_issue] if attributes[:series_volume_issue]
    #attributes[:place].strip! if attributes[:place]
    #attributes[:title] = remove_period remove_italics remove_span remove_bold attributes[:title]
    #attributes[:note] = remove_italics attributes[:note] if attributes[:note]
  end

  def remove_attributes! string
    string.gsub! /<(\w+).*?>/, '<\1>'
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

  def tally_and_show_progress species
    @success_count += 1 if species
    Progress.tally_and_show_progress 100
  end

  def show_results
    Progress.show_count(@success_count, Progress.processed_count, 'successful')
    Progress.show_results
  end

end
