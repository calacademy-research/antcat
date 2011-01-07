class Bolton::GenusCatalog
  def initialize show_progress = false
    Progress.init show_progress
    @success_count = 0
  end

  def clear
    Genus.delete_all
  end

  def import_files filenames
    filenames.each do |filename|
      @filename = filename
      Progress.puts "Importing #{@filename}..."
      import_html File.read @filename
      Progress.show_results
      Progress.puts
    end
    Progress.show_results
  end

  def import_html html
    doc = Nokogiri::HTML html
    @genus = nil
    ps = doc.css('p')
    ps.each do |p|
      parse p.inner_html
    end
  end

  def parse string
    return nil
    string = string.gsub /\n/, ' '
    Bolton::GenusCatalogGrammar.parse(string).value
  rescue Citrus::ParseError => e
    p e
    nil
  end

  def import_genus record
    Genus.create! :name => record[:genus]
    Progress.tally_and_show_progress 100
  end

end
