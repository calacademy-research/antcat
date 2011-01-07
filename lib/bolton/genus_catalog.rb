class Bolton::GenusCatalog
  def initialize show_progress = false
    Progress.init show_progress
    @fossil_count = @unidentifiable_count = 0
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
    summary = ''
    summary << ' ' << Progress.count(@fossil_count, Progress.processed_count, 'fossils').rjust(16)
    summary << ' ' << Progress.count(@unidentifiable_count, Progress.processed_count, 'unidentifiable').rjust(16)
    Progress.puts Progress.results_message + summary
  end

  def import_html html
    Nokogiri::HTML(html).css('p').each do |p|
      next unless record = Bolton::GenusCatalogParser.parse(p.inner_html)
      if record[:unidentifiable]
        @unidentifiable_count += 1
        next
      end
      genus = Genus.create! record[:genus]
      @fossil_count += 1 if genus.fossil?
      Progress.tally_and_show_progress 25
    end
  end

end
