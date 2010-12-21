class Bolton::ReferenceMatcher

  def initialize show_progress = false
    Progress.init show_progress, Bolton::Reference.count
    @unmatched_count = @matched_count = @possible_count = 0
  end

  def find_matches_for_all
    Bolton::Match.transaction do 
      Bolton::Match.delete_all
      Bolton::Reference.all[0,100].each_with_index do |bolton, i|
        find_matches_for bolton
        show_progress
      end
    end
    show_results
  end

  def find_matches_for bolton
    max_confidence = 0
    matches = []
    ward_references_for(bolton).each do |ward|
      confidence = bolton.match ward
      max_confidence = [confidence, max_confidence].max
      next unless confidence > 0
      matches << {:bolton_reference_id => bolton.id, :reference_id => ward.id, :confidence => confidence}
      #next unless reference.author_names.first.last_name == bolton_last_name
      #next unless reference.type == bolton.reference_type
      #next unless reference.matches? bolton
    end

    matches.select do |match|
      match[:confidence] == max_confidence
    end.each do |match|
      Bolton::Match.create! match
    end

    case max_confidence
    when 0 then @unmatched_count += 1
    when 100 then @matched_count += 1
    else @possible_count += 1
    end

  end

  private
  def ward_references_for bolton
    bolton_name = bolton.principal_author_last_name
    if bolton_name != @bolton_name
      @bolton_name = bolton_name
      @references = ::Reference.with_principal_author_last_name bolton_name
    end
    @references
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
