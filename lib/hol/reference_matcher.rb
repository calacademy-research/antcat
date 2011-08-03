class Hol::ReferenceMatcher < ReferenceMatcher

  def match target_reference
    return :book_reference if target_reference.kind_of? BookReference
    matches = super
    return :no_entries_for_author if @no_entries_for_author
    return unless matches.present?
    best_match matches
  end

  def best_match matches
    if matches.size == 1
      match = matches.first if matches.size == 1
    else
      matches = matches.sort_by {|match| match[:similarity]}.reverse
      if matches.first[:similarity] == matches.second[:similarity]
        msg = "Best match found two with same similarity (#{matches.first[:similarity]}):\n"
        msg << "#{matches.first[:match]} and\n"
        msg << "#{matches.second[:match]}"
        Progress.puts msg, true
      end
      match = matches.first
    end
    match[:match]
  end

  def read_references target
    result = Hol::Bibliography.read_references target
    @no_entries_for_author = result.blank?
    result
  end

  def possible_match? target, candidate
    true
  end

  def min_similarity
    0.90
  end

end
