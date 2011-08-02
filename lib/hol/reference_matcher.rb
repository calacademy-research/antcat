class Hol::ReferenceMatcher < ReferenceMatcher

  def match target_reference
    return :book_reference if target_reference.kind_of? BookReference
    matches = super
    return :no_entries_for_author if @no_entries_for_author
    return unless matches.present?
    best_match matches
  end

  def best_match matches
    return matches.first[:match] if matches.size == 1
    matches = matches.sort_by {|match| match[:similarity]}.reverse
    if matches.first[:similarity] == matches.second[:similarity]
      msg = "Best match found two with same similarity (#{matches.first[:similarity]}):\n"
      msg << "#{matches.first[:match]} and\n"
      msg << "#{matches.second[:match]}"
      raise msg
    end
    matches.first[:match]
  end

  def read_references target
    @bibliography ||= Hol::Bibliography.new
    result = @bibliography.read_references target
    @no_entries_for_author = result.blank?
    result
  end

  def possible_match? target, candidate
    true
  end

  def min_similarity
    0.4
  end

end
