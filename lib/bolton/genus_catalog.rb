class Bolton::GenusCatalog
  def initialize show_progress = false
    Progress.init show_progress
    @success_count = 0
  end

  def import_files filenames
    Genus.delete_all
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
    Nokogiri::HTML(html).css('p').each do |p|
      Bolton::GenusCatalogParser.parse p.inner_html
    end
  end

  def import_genus record
    Genus.create! :name => record[:genus]
    Progress.tally_and_show_progress 100
  end

end
