class HolSourceUrlImporter
  def initialize show_progress = false
    Progress.init show_progress
    @bibliography = HolBibliography.new
    @all_count = Reference.count
    @start = Time.now
  end

  def import
    Progress.puts "Importing source URLs..."
    Reference.sorted_by_author.each_with_index do |reference, i|
      Progress.print "Importing source URL for #{reference}"
      import_source_url_for reference
      show_progress i
    end
    show_results
  end

  def import_source_url_for reference
    hol_reference = @bibliography.match reference
    reference.update_attribute(:source_url, hol_reference && hol_reference[:source_url])
  end

  private
  def show_progress i
    elapsed = Time.now - @start
    rate = ((i + 1) / elapsed)
    rate_s = sprintf("%.2f", rate) + "/sec"
    time_left = sprintf("%.0f", (@all_count - i + 1) / rate / 60) + " mins left"

    Progress.puts " #{i + 1}/#{@all_count} #{rate_s} #{time_left}\n"
  end

  def show_results
    Progress.puts
    elapsed = Time.now - @start
    elapsed = sprintf("%.0f mins", elapsed / 60)
    Progress.puts "#{elapsed}. #{@all_count} processed"
  end

end
