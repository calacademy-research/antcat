class HolSourceUrlImporter
  def initialize show_progress = false
    Progress.init show_progress
    @bibliography = HolBibliography.new
    @all_count = Reference.count
    @start = Time.now
    @matched_count = @unmatched_count = 0
    @missing_authors = []
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
    result = @bibliography.match reference
    unless result[:source_url]
      @unmatched_count += 1
      @missing_authors << reference.authors.first.name if result[:failure_reason] == HolBibliography::NO_ENTRIES_FOR_AUTHOR
    else
      @matched_count += 1
    end
    reference.update_attribute(:source_url, result[:source_url])
  end

  def missing_authors
    @missing_authors.uniq.sort
  end

  private
  def show_progress i
    elapsed = Time.now - @start
    rate = ((i + 1) / elapsed)
    rate_s = sprintf("%.2f", rate) + "/sec"
    time_left = sprintf("%.0f", (@all_count - i + 1) / rate / 60) + " mins left"
    unmatched_percent = sprintf("%.0f%%", @unmatched_count * 100.0 / (i + 1))

    Progress.puts " #{i + 1}/#{@all_count} (#{@unmatched_count} unmatched: #{unmatched_percent}) #{rate_s} #{time_left}\n"
  end

  def show_results
    Progress.puts
    elapsed = Time.now - @start
    elapsed = sprintf("%.0f mins", elapsed / 60)
    Progress.puts "#{elapsed}. #{@all_count} processed"
    Progress.puts "#{missing_authors.size} missing authors:\n#{missing_authors.join("\n")}"
  end

end
