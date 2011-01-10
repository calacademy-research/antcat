class Bolton::GenusCatalog
  def initialize show_progress = false
    Progress.init show_progress
    @fossil_count = @unidentifiable_count = @not_genus_count = @unparseable_count = 
    @valid_count = 0
  end

  def import_files filenames
    Genus.delete_all
    filenames.each {|filename| import_file filename }
    show_results
  end

  def import_file filename
    Progress.puts "Importing #{filename}..."
    import_html File.read filename
  end

  def import_html html
    Nokogiri::HTML(html).css('p').each do |p|
      record = Bolton::GenusCatalogParser.parse p.inner_html
      if record == :unparseable
        @unparseable_count += 1
        next
      end
      if record == :unidentifiable
        @unidentifiable_count += 1
        next
      end
      if record == :not_genus
        @not_genus_count += 1
        next
      end
      record[:genus][:is_valid] = record[:genus].delete(:valid)
      genus = Genus.create! record[:genus]
      @fossil_count += 1 if genus.fossil?
      @valid_count += 1 if genus.is_valid?
      Progress.tally_and_show_progress 25
    end
  end

  def show_results
    Progress.show_results
    Progress.puts Progress.count(@valid_count, Progress.processed_count, 'valid')
    Progress.puts Progress.count(@not_genus_count, Progress.processed_count, 'not genus')
    Progress.puts Progress.count(@fossil_count, Progress.processed_count, 'fossils')
    Progress.puts Progress.count(@unidentifiable_count, Progress.processed_count, 'unidentifiable')
    Progress.puts "(#{@unparseable_count} sections unparseable)"
  end

end
