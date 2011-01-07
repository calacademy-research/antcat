class Bolton::GenusCatalog
  def initialize show_progress = false
    Progress.init show_progress
  end

  def import_files filenames
    Genus.delete_all
    filenames.each do |filename|
      Progress.puts "Importing #{filename}..."
      import_html File.read filename
      Progress.show_results
      Progress.puts
    end
    Progress.show_results
  end

  def import_html html
    Nokogiri::HTML(html).css('p').each do |p|
      next unless record = Bolton::GenusCatalogParser.parse(p.inner_html)
      Genus.create! record[:genus]
      Progress.tally_and_show_progress
    end
  end

end
