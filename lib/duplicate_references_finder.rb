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
      DuplicateReference.create! :reference => target, :duplicate => result[:match], :similarity => result[:similarity]
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

class DuplicateReferenceMatcher
  def match target
    matches = candidates_for(target).inject([]) do |matches, candidate|
      if candidate != target && !candidate.duplicates(true).include?(target)
        similarity = target <=> candidate
        matches << {:target => target, :match => candidate, :similarity => similarity} if similarity > 10
      end
      matches
    end || []
    matches
  end

  private
  def candidates_for target
    if target.author != @target_author
      @target_author = target.author
      @candidates = Reference.with_principal_author_last_name @target_author
    end
    @candidates
  end
end

