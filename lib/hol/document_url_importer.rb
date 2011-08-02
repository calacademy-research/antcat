class Hol::DocumentUrlImporter

  attr_reader :success_count,
              :book_failure_count,
              :unknown_count,
              :pdf_not_found_count,
              :missing_author_count,
              :already_imported_count

  def initialize show_progress = false
    Progress.init show_progress, Reference.count
    Progress.open_log
    @matcher = Hol::ReferenceMatcher.new
    @success_count = @unmatched_count = @book_failure_count = @unknown_count =
      @pdf_not_found_count = @missing_author_count = @already_imported_count = 0
    @missing_authors = []
  end

  def import
    Progress.puts "Importing document URLs..."
    Reference.sorted_by_author_name.each do |reference|
      result_string = import_document_url_for reference
      show_progress reference, result_string
    end
    show_results
  end

  def import_document_url_for reference
    if reference.document
      result = :already_imported
    else
      match_result = @matcher.match reference
      if match_result == :no_entries_for_author
        reference.document = nil
        result = match_result
      elsif !match_result
        reference.document = nil
        result = :no_match
      elsif match_result == :book_reference
        reference.document = nil
        result = match_result
      else
        begin
          reference.document = ReferenceDocument.create! :url => match_result.document_url
          result = :success
        rescue ActiveRecord::RecordInvalid
          result = :pdf_not_found
        end
      end
    end
    update_counts reference, result
  end

  def missing_authors
    @missing_authors.uniq.sort
  end

  def processed_count
    Progress.processed_count
  end

  private
  def update_counts reference, result
    if result == :success
      @success_count += 1
      return '* OK *'
    elsif result == :already_imported
      @already_imported_count += 1
      @success_count += 1
      return 'Already'
    else
      if result == :no_entries_for_author
        @missing_authors << reference.author_names.first.name
        @missing_author_count += 1
        return 'Author'
      elsif result == :pdf_not_found
        @pdf_not_found_count += 1
        return 'No PDF'
      elsif result == :book_reference
        @book_failure_count += 1
        return 'Book'
      elsif reference.kind_of? UnknownReference
        @unknown_count += 1
        return 'Unknown'
      else
        @unmatched_count += 1
        return 'Unmatched'
      end
    end
  end

  def show_progress reference, result_string
    Progress.tally
    rate = Progress.rate
    time_left = Progress.time_left
    success_percent = Progress.percent @success_count, Progress.processed_count
    result_string = result_string.ljust(9)
    success = (success_percent + ' success').rjust(12)
    rate = rate.rjust(8)
    time_left = time_left.rjust(13)
    Progress.puts "#{result_string} #{success} #{rate} #{time_left} #{reference}"
  end

  def show_results
    Progress.puts
    Progress.puts "#{missing_authors.size} missing authors:\n#{missing_authors.join("\n")}"

    Progress.puts
    rate = Progress.rate
    elapsed = Progress.elapsed
    Progress.puts "#{Progress.processed_count} processed in #{elapsed} (#{rate})"

    Progress.puts Progress.count(@success_count, Progress.processed_count, 'successful')
    Progress.puts Progress.count(@success_count - @already_imported_count, Progress.processed_count, 'new documents')
    Progress.puts Progress.count(@already_imported_count, Progress.processed_count, 'already imported')
    Progress.puts Progress.count(@missing_author_count, Progress.processed_count, 'author not found')
    Progress.puts Progress.count(@unmatched_count, Progress.processed_count, 'unmatched')
    Progress.puts Progress.count(@unknown_count, Progress.processed_count, 'unknown references')
    Progress.puts Progress.count(@book_failure_count, Progress.processed_count, 'book references')
    Progress.puts Progress.count(@pdf_not_found_count, Progress.processed_count, 'PDF not found')
  end

end
