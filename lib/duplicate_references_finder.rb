class DuplicateReferencesFinder

  def initialize show_progress = false
    Progress.init show_progress, Reference.count
    @duplicate_count = 0
    @matcher = DuplicateReferenceMatcher.new
  end

  def find_duplicates
    DuplicateReference.delete_all
    Reference.all.each do |reference|
      find_duplicates_for reference
      show_progress
    end
    show_results
  end

  private
  def find_duplicates_for target
    results = @matcher.match target
    results.each do |result|
      DuplicateReference.create! :reference_id => target.id, :duplicate_id => result[:match], :similarity => result[:similarity]
    end

    @duplicate_count += 1 if results.present?
  end

  def show_progress
    Progress.tally
    return unless Progress.processed_count % 100 == 0
    Progress.puts Progress.progress_message + progress_stats
  end

  def progress_stats
    message = ''
    message << ' ' << Progress.count(@duplicate_count, Progress.processed_count, 'with duplicate(s)').rjust(20)
  end

  def show_results
    Progress.puts Progress.results_message + progress_stats
  end

end

class DuplicateReferenceMatcher < ReferenceMatcher
  def possible_match? target, candidate
    candidate != target && !candidate.duplicates(true).include?(target)
  end
  def min_similarity
    0.20
  end
end

