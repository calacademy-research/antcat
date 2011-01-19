class Bolton::GenusCatalog
  def initialize show_progress = false
    Progress.init show_progress
    @fossil_count = @unidentifiable_count = @subgenus_count = @unparseable_count = 
      @valid_count = @unavailable_count = 0
  end

  def import_files filenames
    Taxon.delete_all
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
      if record == :subgenus
        @subgenus_count += 1
        next
      end
      record[:genus][:is_valid] = record[:genus].delete(:valid)
      record[:genus][:taxonomic_history] = p.to_html.strip

      subfamily_name = record[:genus].delete(:subfamily)
      tribe_name = record[:genus].delete(:tribe)

      subfamily = subfamily_name && Subfamily.find_or_create_by_name(subfamily_name)
      tribe = tribe_name && Tribe.find_or_create_by_name(tribe_name, :parent => subfamily)

      genus = Genus.find_or_create_by_name record[:genus].merge :parent => tribe || subfamily

      @fossil_count += 1 if genus.fossil?
      @valid_count += 1 if genus.is_valid?
      @unavailable_count += 1 unless genus.available?
      Progress.tally
    end
  end

  def show_results
    Progress.show_results
    Progress.puts Progress.count(@valid_count, Progress.processed_count, 'valid')
    Progress.puts Progress.count(@unavailable_count, Progress.processed_count, 'unavailable')
    Progress.puts Progress.count(@subgenus_count, Progress.processed_count, 'subgenera')
    Progress.puts Progress.count(@fossil_count, Progress.processed_count, 'fossils')
    Progress.puts Progress.count(@unidentifiable_count, Progress.processed_count, 'unidentifiable')
    Progress.puts "(#{@unparseable_count} sections unparseable)"
  end

end
