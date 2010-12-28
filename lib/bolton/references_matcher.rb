class Bolton::ReferencesMatcher

  def initialize show_progress = false
    Progress.init show_progress, Bolton::Reference.count
    @unmatched_count = @matched_count = @possible_count = 0
    @matcher = ::ReferenceMatcher.new
  end

  def find_matches_for_all
    Bolton::Match.transaction do 
      Bolton::Match.delete_all
      #Bolton::Reference.all[0,100].each_with_index do |bolton, i|
      Bolton::Reference.all.each do |bolton|
        find_matches_for bolton
        show_progress
      end
    end
    show_results
  end

  private
  def find_matches_for bolton
    results = @matcher.match bolton
    results[:matches].each do |result|
      Bolton::Match.create! :bolton_reference_id => result[:target], :reference_id => result[:match], :confidence => results[:confidence]
    end

    case 
    when results[:confidence] == 0 then @unmatched_count += 1
    when results[:confidence] < 80 then @possible_count += 1
    else @matched_count += 1
    end

  end

  def show_progress
    Progress.tally
    return unless Progress.processed_count % 10 == 0
    Progress.puts Progress.progress_message + progress_stats
  end

  def progress_stats
    message = ''
    message << ' ' << Progress.count(@matched_count, Progress.processed_count, 'matched').rjust(20)
    message << ' ' << Progress.count(@possible_count, Progress.processed_count, 'possible').rjust(20)
    message << ' ' << Progress.count(@unmatched_count, Progress.processed_count, 'unmatched').rjust(20)
  end

  def show_results
    Progress.puts Progress.results_message + progress_stats
  end

end
