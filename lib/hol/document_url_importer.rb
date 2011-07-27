class Hol::DocumentUrlImporter

  attr_reader :success_count,
              :book_failure_count,
              :unknown_count,
              :pdf_not_found_count,
              :missing_author_count,
              :already_imported_count

  def initialize show_progress = false
    Progress.init show_progress, Reference.count
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
      result = {:status => :already_imported}
    else
      result = @matcher.match reference
      unless result[:document_url]
        reference.document = nil
      else
        begin
          reference.document = ReferenceDocument.create! :url => result[:document_url]
        rescue ActiveRecord::RecordInvalid
          result[:document_url] = nil
          result[:status] = :pdf_not_found
        end
      end
      reference.save!
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
    if result[:document_url]
      @success_count += 1
      return '* OK *'
    elsif result[:status] == :already_imported
      @already_imported_count += 1
      @success_count += 1
      return 'Already'
    else
      if result[:status] == :no_entries_for_author
        @missing_authors << reference.author_names.first.name
        @missing_author_count += 1
        return 'Author'
      elsif result[:status] == :pdf_not_found
        @pdf_not_found_count += 1
        return 'No PDF'
      elsif reference.kind_of? BookReference
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

  def document_url_exists? document_url
    (200..399).include? Curl::Easy.http_head(document_url).response_code
  end
end
